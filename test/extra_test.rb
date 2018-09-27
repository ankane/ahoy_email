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

  def test_proc
    skip unless params_supported?
    ExtraMailer.with(coupon_id: 2).other.deliver_now
    assert_equal 2, ahoy_message.coupon_id
  end

  def test_proc_no_params
    ExtraMailer.other_no_params(2).deliver_now
    assert_equal 2, ahoy_message.coupon_id
  end
end
