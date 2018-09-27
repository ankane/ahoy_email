require_relative "test_helper"

class UtmParamsMailer < ApplicationMailer
  track utm_params: true, except: [:welcome]

  def welcome
    html_message('<a href="https://example.org">Test</a>')
  end

  def basic
    html_message('<a href="https://example.org">Test</a>')
  end

  def array_params
    html_message('<a href="https://example.org?baz[]=1&amp;baz[]=2">Hi<a>')
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

  def test_array_params
    message = UtmParamsMailer.array_params.deliver_now
    body = message.body.to_s
    assert_match "baz%5B%5D=1&amp;baz%5B%5D=2", body
  end
end
