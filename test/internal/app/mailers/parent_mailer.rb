class ParentMailer < ApplicationMailer
  has_history

  def welcome
    mail
  end

  def other
    mail
  end
end
