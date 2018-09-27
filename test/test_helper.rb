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

# class UserMailer < ActionMailer::Base
#   default from: "from@example.com"
#   after_action :prevent_delivery_to_guests, only: [:welcome2]

#   def welcome
#     mail to: "test@example.org", subject: "Hello", body: "World"
#   end

#   def welcome2
#     mail to: "test@example.org", subject: "Hello", body: "World"
#   end

#   def welcome3
#     track message: false
#     mail to: "test@example.org", subject: "Hello", body: "World"
#   end

#   def welcome4
#     html_message('<a href="https://example.org">Hi<a>')
#   end

#   def welcome5
#     html_message('<a href="https://example.org?baz[]=1&amp;baz[]=2">Hi<a>')
#   end

#   def heuristic_parse
#     track heuristic_parse: true
#     html_message('<a href="example.org">Hi<a>')
#   end

#   def mailto
#     track heuristic_parse: true
#     html_message('<a href="mailto:someone@yoursite.com">Email Us</a>')
#   end

#   def app_link
#     track heuristic_parse: true
#     html_message('<a href="fb://profile/33138223345">Email Us</a>')
#   end

#   def welcome4_heuristic
#     track heuristic_parse: true
#     html_message('<a href="https://example.org">Hi<a>')
#   end

#   def welcome5_heuristic
#     track heuristic_parse: true
#     html_message('<a href="https://example.org?baz[]=1&amp;baz[]=2">Hi<a>')
#   end

#   private

#   def prevent_delivery_to_guests
#     mail.perform_deliveries = false
#   end

#   def html_message(html)
#     track click: false
#     mail to: "test@example.org", subject: "Hello" do |format|
#       format.html { render plain: html }
#     end
#   end
# end
