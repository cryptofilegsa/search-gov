namespace :usasearch do
  namespace :twitter do

    task :refresh_lists, [:host] => :environment do |t, args|
      TwitterData.configure_twitter_auth(args.host)
      ContinuousWorker.start { TwitterData.refresh_lists }
    end

    task :refresh_lists_statuses, [:host] => :environment do |t, args|
      TwitterData.configure_twitter_auth(args.host)
      ContinuousWorker.start { TwitterData.refresh_lists_statuses }
    end

    desc "Connect to Twitter Streaming API and capture tweets from all customer twitter accounts"
    task :stream, [:host] => [:environment] do |t, args|
      logger = ActiveSupport::BufferedLogger.new(Rails.root.to_s + "/log/twitter.log")
      twitter_config = YAML.load_file("#{Rails.root}/config/twitter.yml")
      args.with_defaults(host: 'default')

      auth_info = twitter_config[args.host] ? twitter_config[args.host] : twitter_config['default']
      TweetStream.configure do |config|
        auth_info.each do |key, value|
          config.send("#{key}=", value)
        end
      end

      EM.run do
        twitter_client = TweetStream::Client.new

        twitter_client.on_error { |message| logger.error "[#{Time.now}] [TWITTER] [ERROR] #{message}" }
        twitter_client.on_limit { |skip_count| logger.info "[#{Time.now}] [TWITTER] [LIMIT] skip count: #{skip_count}" }

        twitter_client.on_reconnect do |timeout, retries|
          logger.info "[#{Time.now}] [TWITTER] [RECONNECT] Reconnecting timeout: #{timeout} retries: #{retries}"
        end

        twitter_client.on_delete do |status_id, user_id|
          logger.info "[#{Time.now}] [TWITTER] [ONDELETE] Received delete request for status##{status_id}"
          Tweet.destroy_all(:tweet_id => status_id)
        end

        do_follow = lambda do |twitter_client|
          twitter_ids = TwitterProfile.affiliate_twitter_ids
          if twitter_ids.present?
            logger.info "[#{Time.now}] [TWITTER] [CONNECT] Connecting to Twitter to follow #{twitter_ids.size} Twitter profiles."

            twitter_client.follow(twitter_ids) do |status|
              logger.info "[#{Time.now}] [TWITTER] [FOLLOW] New tweet received: @#{status.user.screen_name}: #{status.text}"
              begin
                TwitterData.import_tweet(status) if twitter_ids.include?(status.user.id)
              rescue Exception => e
                logger.error "[#{Time.now}] [TWITTER] [FOLLOW] [ERROR] Encountered error while handling tweet with status_id=#{status.id}: #{e.message}"
              end
            end
          end
        end

        do_follow.call(twitter_client)

        EventMachine.add_periodic_timer(300) do
          logger.info "[#{Time.now}] [TWITTER] [RESET_STREAM]"
          twitter_client.stop_stream
          do_follow.call(twitter_client)
        end
      end
    end
  end
end
