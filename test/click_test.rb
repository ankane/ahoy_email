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
  end

  def test_query_params
    message = ClickMailer.query_params.deliver_now
    assert_body "click", message

    click_link(message)
    assert_redirected_to "https://example.org?a=1&b=2"
  end

  def test_campaign
    ClickMailer.query_params.deliver_now
    assert_equal "test", ahoy_message.campaign
  end

  def test_bad_signature
    message = ClickMailer.basic.deliver_now
    assert_body "click", message
    url = /a href=\"([^"]+)\"/.match(message.body.decoded)[1]
    get url.sub(/\bs=/, "s=bad")
    assert_response :not_found
    assert_equal "Link expired", response.body
  end

  def test_invalid_redirect_url
    with_invalid_redirect_url("https://example.com/not_found") do
      message = ClickMailer.basic.deliver_now
      assert_body "click", message
      url = /a href=\"([^"]+)\"/.match(message.body.decoded)[1]
      get url.sub(/\bs=/, "s=bad")
      assert_redirected_to "https://example.com/not_found"
    end
  end

  def test_consistent_signature
    get AhoyEmail::Engine.routes.url_helpers.click_path(c: "test", s: "AgVw_k8ckEXXHdlG0OZ8raH0OVir3LYAivnV3E0HRZU", t: "123", u: "https://example.org")
    assert_redirected_to "https://example.org"
  end

  def test_bad_signature_direct
    get AhoyEmail::Engine.routes.url_helpers.click_path(c: "test", s: "bad", t: "123", u: "https://example.org")
    assert_response :not_found
    assert_equal "Link expired", response.body
  end

  def test_legacy_secret_token_signature
    with_secret_token([AhoyEmail.secret_token, "0" * 128]) do
      get AhoyEmail::Engine.routes.url_helpers.click_path(c: "test", s: "ncBvGv-Q804GPmVf1JzHm767cx4CmGLrc1mwR0KFnLY", t: "123", u: "https://example.org")
      assert_redirected_to "https://example.org"
    end
  end

  def test_legacy_route_signature
    with_secret_token("0" * 128) do
      get AhoyEmail::Engine.routes.url_helpers.click_message_path("123", signature: "d77812b6f1406cff37c4ee6fcfc744b986281c5c", url: "https://example.org")
      assert_redirected_to "https://example.org"
    end
  end

  def test_legacy_route_bad_signature
    with_secret_token("0" * 128) do
      get AhoyEmail::Engine.routes.url_helpers.click_message_path("123", signature: "bad", url: "https://example.org")
      assert_response :not_found
      assert_equal "Link expired", response.body
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
    message = ClickMailer.with(condition: false).conditional.deliver_now
    refute_body "click", message

    message = ClickMailer.with(condition: true).conditional.deliver_now
    assert_body "click", message
  end

  def test_default_url_options
    with_value(ActionMailer::Base, :default_url_options, {host: "example.net"}) do
      message = ClickMailer.basic.deliver_now
      assert_body "example.net", message
    end
  end

  def test_default_url_options_mailer
    message = UrlOptionsMailer.basic.deliver_now
    assert_body "example.net", message
  end

  def test_missing_campaign_keyword
    error = assert_raises(ArgumentError) do
      ClickMailer.track_clicks
    end
    assert_equal "missing keyword: :campaign", error.message
  end

  def with_invalid_redirect_url(value)
    with_value(AhoyEmail, :invalid_redirect_url, value) do
      yield
    end
  end

  def with_secret_token(value)
    with_value(AhoyEmail, :secret_token, value) do
      yield
    end
  end
end
