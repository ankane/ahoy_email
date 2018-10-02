Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO if defined?(Mongo::Logger)

Mongoid.configure do |config|
  config.connect_to "ahoy_email_test"
end

class User
  include Mongoid::Document

  field :email, type: String
end

class Ahoy::Message
  include Mongoid::Document

  belongs_to :user, polymorphic: true, optional: true, index: true

  field :to, type: String
  field :mailer, type: String
  field :subject, type: String
  field :sent_at, type: Time

  field :coupon_id, type: Integer

  field :content, type: String
  field :utm_source, type: String
  field :utm_campaign, type: String
  field :utm_term, type: String
  field :utm_medium, type: String
  field :utm_content, type: String
end
