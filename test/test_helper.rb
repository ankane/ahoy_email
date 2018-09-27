require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "combustion"

Combustion.path = "test/internal"
Combustion.initialize! :all do
  if config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

ActionMailer::Base.delivery_method = :test

class User < ActiveRecord::Base
end

class ApplicationMailer < ActionMailer::Base
  default from: "from@example.org",
          to: -> { (params && params[:to]) || "to@example.org" },
          subject: "Hello",
          body: "World"

  def html_message(html)
    mail do |format|
      format.html { render plain: html }
    end
  end
end

class Minitest::Test
  def setup
    Ahoy::Message.delete_all
  end

  def ahoy_message
    Ahoy::Message.last
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
