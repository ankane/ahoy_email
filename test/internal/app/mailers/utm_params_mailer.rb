class UtmParamsMailer < ApplicationMailer
  track utm_params: true, except: [:welcome]

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
end
