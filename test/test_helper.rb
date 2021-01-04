require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

AhoyEmail.api = true

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_mailer do
  if ActiveRecord::VERSION::MAJOR < 6 && config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

require_relative "support/mongoid" if defined?(Mongoid)

ActionMailer::Base.delivery_method = :test

class EmailSubscriber
  def open(event)
    $open_events << event
  end

  def click(event)
    $click_events << event
  end
end

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

  def params_supported?
    Rails.version > "5.1.0"
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
