class UserMailer < ApplicationMailer
  track user: -> { @some_user }, only: [:dynamic]

  def welcome
    mail
  end

  def to_field(to)
    mail to: to
  end

  def dynamic(some_user)
    @some_user = some_user
    mail
  end
end
