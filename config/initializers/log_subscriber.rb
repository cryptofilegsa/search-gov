module Instrumentation
  class LogSubscriber < ActiveSupport::LogSubscriber
    def best_bets_drill_down(event)
      generic_logging("Keen Best Bets Query", event, CYAN)
    end

    def best_bets_publish(event)
      generic_logging("Keen Best Bets Publish", event, CYAN)
    end

    def bing_image_search(event)
      generic_logging("Bing Image Query", event, YELLOW)
    end

    def bing_web_search(event)
      generic_logging("Bing Query", event, YELLOW)
    end

    def google_web_search(event)
      generic_logging("Google Query", event, RED)
    end

    def elastic_search(event)
      generic_logging("#{event.payload[:index]} Query", event, MAGENTA)
    end

    private
    def generic_logging(label, event, color)
      name = '%s (%.1fms)' % [label, event.duration]
      query = event.payload[:query].to_json
      info "  #{color(name, color, true)}  #{query}"
    end
  end
end

Instrumentation::LogSubscriber.attach_to :usasearch

ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  Rails.logger.info('[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration])
end
