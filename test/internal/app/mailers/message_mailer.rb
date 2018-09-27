class MessageMailer < ApplicationMailer
  track message: false, only: [:other]
  track message: true, only: [:other2]

  after_action :prevent_delivery

  def welcome
    mail
  end

  def other
    mail
  end

  def other2
    mail
  end

  private

  def prevent_delivery
    mail.perform_deliveries = false if params && params[:deliver] == false
  end
end
