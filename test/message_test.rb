require_relative "test_helper"

class MessageMailer < ApplicationMailer
  track message: false, only: [:other]

  def welcome
    mail
  end

  def other
    mail
  end
end

class MessageTest < Minitest::Test
  def test_default
    MessageMailer.welcome.deliver_now
    assert ahoy_message
  end

  def test_false
    MessageMailer.other.deliver_now
    assert_nil ahoy_message
  end
end
