require_relative "test_helper"

class UserMailer < ActionMailer::Base
  def welcome
    mail to: "test@example.org", subject: "Hello", body: "World"
  end
end

class MailerTest < Minitest::Test
  def test_basic
    message = UserMailer.welcome
    message.to # trigger creation

    ahoy_message = Ahoy::Message.first
    assert_equal 1, Ahoy::Message.count
    assert_equal "test@example.org", ahoy_message.to
    assert_equal "UserMailer#welcome", ahoy_message.mailer
    assert_equal "Hello", ahoy_message.subject
    assert_equal "user_mailer", ahoy_message.utm_source
    assert_equal "email", ahoy_message.utm_medium
    assert_equal "welcome", ahoy_message.utm_campaign
  end
end
