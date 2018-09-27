class UserMailer < ApplicationMailer
  track user: -> { @some_user }, only: [:other]

  def welcome
    mail
  end

  def other(some_user)
    @some_user = some_user
    mail
  end

  def welcome_to(to)
    mail to: to
  end
end
