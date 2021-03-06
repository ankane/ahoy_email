class ClickMailer < ApplicationMailer
  track_clicks campaign: "test", except: [:welcome, :conditional, :campaignless]
  track_clicks campaign: "test", if: -> { params[:condition] }, only: [:conditional]
  track_clicks campaign: false, only: [:campaignless]
  has_history only: [:campaignless, :query_params]

  def welcome
    mail_html('<a href="https://example.org">Test</a>')
  end

  def basic
    mail_html('<a href="https://example.org">Test</a>')
  end

  def query_params
    mail_html('<a href="https://example.org?a=1&b=2">Test</a>')
  end

  def mailto
    mail_html('<a href="mailto:hi@example.org">Test</a>')
  end

  def app
    mail_html('<a href="fb://profile/33138223345">Test</a>')
  end

  def schemeless
    mail_html('<a href="example.org">Test</a>')
  end

  def campaignless
    mail_html('<a href="https://example.org">Test</a>')
  end

  def conditional
    mail_html('<a href="https://example.org">Test</a>')
  end
end
