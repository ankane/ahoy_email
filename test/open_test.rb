require_relative "test_helper"

class OpenTest < ActionDispatch::IntegrationTest
  def test_default
    message = OpenMailer.welcome.deliver_now
    refute_body "open.gif", message
  end

  def test_basic
    message = OpenMailer.basic.deliver_now
    assert_body "open.gif", message

    open_message(message)
    assert_response :success
    assert ahoy_message.opened_at
  end

  def test_subscriber
    with_subscriber(EmailSubscriber.new) do
      message = OpenMailer.basic.deliver_now
      open_message(message)

      assert_equal 1, $open_events.size
      open_event = $open_events.first
      assert_equal ahoy_message, open_event[:message]
      assert open_event[:token]
    end
  end

  def open_message(message)
    url = /src=\"([^"]+)\"/.match(message.body.decoded)[1]
    get url
  end
end
