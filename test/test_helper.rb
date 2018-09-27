require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

Combustion.path = "test/internal"
Combustion.initialize! :all do
  if config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

if defined?(Mongoid)
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
  end
end

ActionMailer::Base.delivery_method = :test

class Minitest::Test
  def setup
    Ahoy::Message.delete_all
  end

  def ahoy_message
    Ahoy::Message.last
  end

  def refute_body(str, message)
    refute_match str, message.body.decoded
  end

  def assert_body(str, message)
    assert_match str, message.body.decoded
  end

  def with_default(options)
    previous_options = AhoyEmail.default_options.dup
    begin
      AhoyEmail.default_options.merge!(options)
      yield
    ensure
      AhoyEmail.default_options = previous_options
    end
  end
end
