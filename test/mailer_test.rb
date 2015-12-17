require_relative "test_helper"

class UserMailer < ActionMailer::Base
  after_action :prevent_delivery_to_guests, only: [:welcome2]

  def welcome
    mail to: "test@example.org", subject: "Hello", body: "World"
  end

  def welcome2
    mail to: "test@example.org", subject: "Hello", body: "World"
  end

  private

  def prevent_delivery_to_guests
    mail.perform_deliveries = false
  end
end

class MailerTest < Minitest::Test
  def setup
    Ahoy::Message.delete_all
  end

  def test_basic
    assert_message :welcome
  end

  def test_prevent_delivery
    assert_message :welcome2
  end

  def assert_message(method)
    message = UserMailer.send(method)
    message.to # trigger creation
    ahoy_message = Ahoy::Message.first
    assert_equal 1, Ahoy::Message.count
    assert_equal "test@example.org", ahoy_message.to
    assert_equal "UserMailer##{method}", ahoy_message.mailer
    assert_equal "Hello", ahoy_message.subject
    assert_equal "user_mailer", ahoy_message.utm_source
    assert_equal "email", ahoy_message.utm_medium
    assert_equal method.to_s, ahoy_message.utm_campaign
  end
end
