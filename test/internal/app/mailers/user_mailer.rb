class UserMailer < ApplicationMailer
  track user: -> { params[:some_user] }, only: [:other]

  def welcome
    mail
  end

  def other
    mail
  end
end
