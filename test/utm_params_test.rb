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
    assert_includes message.to_s, %!<a href="https://chartkick.com">Test</a>!
  end

  # def test_basic
  #   message = UtmParamsMailer.basic.deliver_now
  #   assert_includes message.to_s, %!<a href="https://chartkick.com?utm_medium=email">Test</a>!
  # end
end
