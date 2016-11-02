require_relative "test_helper"

class UserMailer < ActionMailer::Base
  default from: "from@example.com"
  after_action :prevent_delivery_to_guests, only: [:welcome2] if Rails.version >= "4.0.0"

  def welcome
    mail to: "test@example.org", subject: "Hello", body: "World"
  end

  def welcome2
    mail to: "test@example.org", subject: "Hello", body: "World"
  end

  def welcome3
    track message: false
    mail to: "test@example.org", subject: "Hello", body: "World"
  end

  def welcome4
    track message: true, utm_params: "baz", click: true

    mail to: "test@example.org", subject: "Hello, World"
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
    if Rails.version >= "4.0.0"
      assert_nil Ahoy::Message.first.sent_at
    end
  end

  def test_no_message
    UserMailer.welcome3.to
    assert_equal 0, Ahoy::Message.count
  end

  def assert_message(method)
    message = UserMailer.send(method)
    message.respond_to?(:deliver_now) ? message.deliver_now : message.deliver
    ahoy_message = Ahoy::Message.first
    assert_equal 1, Ahoy::Message.count
    assert_equal "test@example.org", ahoy_message.to
    assert_equal "UserMailer##{method}", ahoy_message.mailer
    assert_equal "Hello", ahoy_message.subject
    assert_equal "user_mailer", ahoy_message.utm_source
    assert_equal "email", ahoy_message.utm_medium
    assert_equal method.to_s, ahoy_message.utm_campaign
  end

  def test_handling_array_params
    message = UserMailer.send(:welcome4)
    message.respond_to?(:deliver_now) ? message.deliver_now : message.deliver
    ahoy_message = Ahoy::Message.first
    assert_equal 1, Ahoy::Message.count

    pp [:ahoy, ahoy_message]

    # message = UserMailer.send(method)
    # message.respond_to?(:deliver_now) ? message.deliver_now : message.deliver
    # ahoy_message = Ahoy::Message.first
    # assert_equal 1, Ahoy::Message.count
    # assert_equal "test@example.org", ahoy_message.to
    # assert_equal "UserMailer##{method}", ahoy_message.mailer
    # assert_equal "Hello", ahoy_message.subject
    # assert_equal "user_mailer", ahoy_message.utm_source
    # assert_equal "email", ahoy_message.utm_medium
    # assert_equal method.to_s, ahoy_message.utm_campaign
  end
end
