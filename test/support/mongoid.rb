Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO if defined?(Mongo::Logger)

Mongoid.configure do |config|
  config.connect_to "ahoy_email_test"
end
