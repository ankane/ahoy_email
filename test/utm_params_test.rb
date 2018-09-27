require_relative "test_helper"

class UtmParamsMailer < ApplicationMailer
  track utm_params: true, only: [:basic]

  def welcome
    html_message(%!<a href="https://chartkick.com">Test</a>!)
  end

  def basic
    html_message(%!<a href="https://chartkick.com">Test</a>!)
  end
end

class UtmParamsTest < Minitest::Test
  def test_default
    message = UtmParamsMailer.welcome.deliver_now
    body = message.body.to_s
    refute_match "utm", body
  end

  def test_basic
    message = UtmParamsMailer.basic.deliver_now
    body = message.body.to_s
    assert_match "utm_campaign=basic", body
    assert_match "utm_medium=email", body
    assert_match "utm_source=utm_params_mailer", body
  end
end
