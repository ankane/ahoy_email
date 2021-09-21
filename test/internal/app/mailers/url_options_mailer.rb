class UrlOptionsMailer < ApplicationMailer
  track_clicks campaign: "test"

  def basic
    mail_html('<a href="https://example.org">Test</a>')
  end

  def default_url_options
    {host: "example.net"}
  end
end
