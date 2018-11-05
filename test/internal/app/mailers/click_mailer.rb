class ClickMailer < ApplicationMailer
  track click: true, except: [:welcome]

  def welcome
    mail_html('<a href="https://example.org">Test</a>')
  end

  def basic
    mail_html('<a href="https://example.org">Test</a>')
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
end
