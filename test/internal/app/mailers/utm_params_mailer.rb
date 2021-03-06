class UtmParamsMailer < ApplicationMailer
  utm_params except: [:welcome]
  utm_params utm_campaign: "first", only: [:multiple]
  utm_params utm_campaign: "second", only: [:multiple]
  has_history only: [:welcome, :basic]

  def welcome
    mail_html('<a href="https://example.org">Test</a>')
  end

  def basic
    mail_html('<a href="https://example.org">Test</a>')
  end

  def array_params
    mail_html('<a href="https://example.org?baz[]=1&amp;baz[]=2">Hi<a>')
  end

  def nested
    mail_html('<a href="https://example.org"><img src="image.png"></a>')
  end

  def multiple
    mail_html('<a href="https://example.org">Test</a>')
  end
end
