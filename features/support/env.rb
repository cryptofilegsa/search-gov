require 'simplecov'
SimpleCov.command_name 'Cucumber'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require 'capybara/rails'
require 'email_spec/cucumber'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_wait_time = 10

require 'capybara/poltergeist'
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new app, port: 8899, js_errors: false
end
Capybara.javascript_driver = :poltergeist

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
  Cucumber::Rails::Database.javascript_strategy = :truncation, { except: %w(email_templates) }
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Dir.mkdir("#{Rails.root}/tmp/cache") unless File.directory?("#{Rails.root}/tmp/cache")
Dir.mkdir("#{Rails.root}/tmp/pids") unless File.directory?("#{Rails.root}/tmp/pids")
REDIS_PID = "#{Rails.root}/tmp/pids/redis-test.pid"
REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache/"
redis_options = {
  "daemonize" => 'yes',
  "pidfile" => REDIS_PID,
  "port" => 6380,
  "timeout" => 300,
  "save 900" => 1,
  "save 300" => 1,
  "save 60" => 10000,
  "dbfilename" => "dump.rdb",
  "dir" => REDIS_CACHE_PATH,
  "loglevel" => "debug",
  "logfile" => "stdout",
  "databases" => 16
}.map { |k, v| "#{k} #{v}" }.join("\n")
`echo '#{redis_options}' | redis-server -`

EmailTemplate.load_default_templates

at_exit do
  %x{
    cat #{REDIS_PID} | xargs kill -9
    rm -f #{REDIS_CACHE_PATH}dump.rdb
  }
end

# EventMachine instance for Keen IO
Thread.new { EventMachine.run }
