require_relative "test_helper"

class ClickTest < ActionDispatch::IntegrationTest
  def test_default
    message = ClickMailer.welcome.deliver_now
    refute_body "click", message
  end

  def test_basic
    message = ClickMailer.basic.deliver_now
    assert_body "click", message

    click_link(message)
    assert_redirected_to "https://example.org"
    assert ahoy_message.clicked_at
  end

  def test_query_params
    message = ClickMailer.query_params.deliver_now
    assert_body "click", message

    click_link(message)
    assert_redirected_to "https://example.org?a=1&b=2"
    assert ahoy_message.clicked_at
  end

  def test_subscriber
    with_subscriber(EmailSubscriber.new) do
      message = ClickMailer.basic.deliver_now
      click_link(message)

      assert_equal 1, $click_events.size
      click_event = $click_events.first
      assert_equal "https://example.org", click_event[:url]
      assert_equal ahoy_message, click_event[:message]
      assert click_event[:token]
    end
  end

  def test_subscriber_class
    with_subscriber(EmailSubscriber) do
      message = ClickMailer.basic.deliver_now
      click_link(message)

      assert_equal 1, $click_events.size
      click_event = $click_events.first
      assert_equal "https://example.org", click_event[:url]
      assert_equal ahoy_message, click_event[:message]
      assert click_event[:token]
    end
  end

  def test_bad_signature
    message = ClickMailer.basic.deliver_now
    assert_body "click", message
    url = /a href=\"([^"]+)\"/.match(message.body.decoded)[1]
    get url.sub("signature=", "signature=bad")
    assert_redirected_to root_url
  end

  def test_missing_message
    with_subscriber(EmailSubscriber) do
      message = ClickMailer.basic.deliver_now
      token = ahoy_message.token
      Ahoy::Message.delete_all
      click_link(message)

      assert_equal 1, $click_events.size
      click_event = $click_events.first
      assert_equal "https://example.org", click_event[:url]
      assert_nil click_event[:message]
      assert_equal token, click_event[:token]
    end
  end

  def test_mailto
    message = ClickMailer.mailto.deliver_now
    assert_body '<a href="mailto:hi@example.org">', message
  end

  def test_app
    message = ClickMailer.app.deliver_now
    assert_body '<a href="fb://profile/33138223345">', message
  end

  def test_schemeless
    message = ClickMailer.schemeless.deliver_now
    assert_body "click", message
  end

  def test_conditional
    message = ClickMailer.conditional(false).deliver_now
    refute_body "click", message

    message = ClickMailer.conditional(true).deliver_now
    assert_body "click", message
  end

  def click_link(message)
    url = /href=\"([^"]+)\"/.match(message.body.decoded)[1]

    # unescape entities like browser does
    url = CGI.unescapeHTML(url)

    get url
  end
end
