require_relative "test_helper"

class ClickMailer < ApplicationMailer
  track click: true, only: [:basic]

  def welcome
    mail_html('<a href="https://example.org">Test</a>')
  end

  def basic
    mail_html('<a href="https://example.org">Test</a>')
  end
end

class ClickTest < Minitest::Test
  def test_default
    message = ClickMailer.welcome.deliver_now
    refute_body "click", message
  end

  def test_basic
    message = ClickMailer.basic.deliver_now
    assert_body "click", message
  end
end
