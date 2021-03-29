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

  def head_element
    mail_html('<html><head><style>a {color: red;}</style></head></html>')
  end

  def doctype
    mail_html('<!DOCTYPE html><html></html>')
  end

  def body_style
    mail_html('<html><body style="background-color:#ABC123;"></body></html>')
  end
end
