class OpenMailer < ApplicationMailer
  track open: true, only: [:basic]

  def welcome
    mail_html('Hi')
  end

  def basic
    mail_html('Hi')
  end
end
