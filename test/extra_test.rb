require_relative "test_helper"

class ExtraTest < Minitest::Test
  def test_default
    ExtraMailer.welcome.deliver_now
    assert_nil ahoy_message.coupon_id
  end

  def test_static
    ExtraMailer.basic.deliver_now
    assert_equal 1, ahoy_message.coupon_id
  end

  def test_dynamic
    ExtraMailer.other(2).deliver_now
    assert_equal 2, ahoy_message.coupon_id
  end
end
