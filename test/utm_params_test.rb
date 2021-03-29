require_relative "test_helper"

class UtmParamsTest < Minitest::Test
  def test_default
    message = UtmParamsMailer.welcome.deliver_now
    refute_body "utm", message
    assert_nil ahoy_message.utm_campaign
    assert_nil ahoy_message.utm_medium
    assert_nil ahoy_message.utm_source
  end

  def test_basic
    message = UtmParamsMailer.basic.deliver_now
    assert_body "utm_campaign=basic", message
    assert_body "utm_medium=email", message
    assert_body "utm_source=utm_params_mailer", message
    assert_equal "basic", ahoy_message.utm_campaign
    assert_equal "email", ahoy_message.utm_medium
    assert_equal "utm_params_mailer", ahoy_message.utm_source
  end

  def test_array_params
    message = UtmParamsMailer.array_params.deliver_now
    assert_body "baz%5B%5D=1&amp;baz%5B%5D=2", message
  end

  def test_nested
    message = UtmParamsMailer.nested.deliver_now
    assert_body "utm_medium=email", message
    assert_body '<img src="image.png"></a>', message
  end

  def test_multiple
    message = UtmParamsMailer.multiple.deliver_now
    assert_body "utm_campaign=second", message
  end

  def test_head_element
    message = UtmParamsMailer.head_element.deliver_now
    assert_body '<head>', message
    assert_body '</head>', message
  end

  def test_doctype
    message = UtmParamsMailer.doctype.deliver_now
    assert_body '<!DOCTYPE html>', message
  end

  def test_body_style
    message = UtmParamsMailer.body_style.deliver_now
    assert_body '<body style="background-color:#ABC123;">', message
  end
end
