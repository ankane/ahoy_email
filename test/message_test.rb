require_relative "test_helper"

class MessageTest < Minitest::Test
  def test_default
    MessageMailer.welcome.deliver_now
    assert ahoy_message
  end

  def test_false
    MessageMailer.other.deliver_now
    assert_nil ahoy_message
  end

  def test_prevent_delivery
    MessageMailer.with(deliver: false).welcome.deliver_now
    assert_nil ahoy_message
  end

  def test_default_false
    with_default(message: false) do
      MessageMailer.welcome.deliver_now
      assert_nil ahoy_message
    end
  end

  def test_default_false_track
    with_default(message: false) do
      MessageMailer.other2.deliver_now
      assert ahoy_message
    end
  end
end
