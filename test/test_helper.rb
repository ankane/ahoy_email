require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

$logger = ActiveSupport::Logger.new(ENV["VERBOSE"] ? STDOUT : nil)

AhoyEmail.api = true

Combustion.path = "test/internal"

def mongoid?
  defined?(Mongoid)
end

if mongoid?
  Combustion.initialize! :action_mailer, :action_controller do
    config.logger = $logger
  end
  require_relative "support/mongoid"
else
  Combustion.initialize! :action_mailer, :action_controller, :active_record do
    if ActiveRecord::VERSION::MAJOR < 6 && config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
      config.active_record.sqlite3.represent_boolean_as_integer = true
    end
    config.logger = $logger
  end
end

ActionMailer::Base.delivery_method = :test

class EmailSubscriber
  def track_send(data)
    $send_events << data
  end

  def track_click(data)
    $click_events << data
  end

  def stats
    {sends: $send_events.size, clicks: $click_events.size}
  end
end

class LegacyEmailSubscriber
  def click(data)
    $click_events << data
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

  def with_default(options)
    previous_options = AhoyEmail.default_options.dup
    begin
      AhoyEmail.default_options.merge!(options)
      yield
    ensure
      AhoyEmail.default_options = previous_options
    end
  end

  def with_save_token
    previous_value = AhoyEmail.save_token
    begin
      AhoyEmail.save_token = true
      yield
    ensure
      AhoyEmail.save_token = previous_value
    end
  end
end

class ActionDispatch::IntegrationTest
  def click_link(message)
    url = /href=\"([^"]+)\"/.match(message.body.decoded)[1]

    # unescape entities like browser does
    url = CGI.unescapeHTML(url)

    get url
  end
end
