require_relative "test_helper"

class OpenMailer < ApplicationMailer
  track open: true, only: [:basic]

  def welcome
    mail_html('Hi')
  end

  def basic
    mail_html('Hi')
  end
end

class OpenTest < Minitest::Test
  def test_default
    message = OpenMailer.welcome.deliver_now
    refute_body "open.gif", message
  end

  def test_basic
    message = OpenMailer.basic.deliver_now
    assert_body "open.gif", message
  end
end
