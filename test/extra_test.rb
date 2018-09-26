require_relative "test_helper"

class ExtraMailer < ApplicationMailer
  track extra: {coupon_id: 1}, only: [:welcome]
  track extra: -> { {coupon_id: params[:coupon_id]} }, only: [:other]

  def welcome
    mail
  end

  def other
    mail
  end
end

class ExtraTest < Minitest::Test
  def test_string
    ExtraMailer.welcome.deliver_now
    assert_equal 1, ahoy_message.coupon_id
  end

  def test_proc
    ExtraMailer.with(coupon_id: 2).other.deliver_now
    assert_equal 2, ahoy_message.coupon_id
  end
end
