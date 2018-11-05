require_relative "test_helper"

class MessageTest < Minitest::Test
  def test_default
    MessageMailer.welcome.deliver_now
    assert ahoy_message
    assert_equal "Hello", ahoy_message.subject
    assert_match "Hello", ahoy_message.content
    assert_match "World", ahoy_message.content
  end

  def test_false
    MessageMailer.other.deliver_now
    assert_nil ahoy_message
  end

  def test_prevent_delivery
    MessageMailer.no_deliver.deliver_now
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

  def test_ahoy_message
    message = MessageMailer.welcome.deliver_now
    assert_equal message.ahoy_message, ahoy_message
  end
end
