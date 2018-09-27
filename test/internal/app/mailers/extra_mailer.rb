class ExtraMailer < ApplicationMailer
  track extra: {coupon_id: 1}, only: [:welcome]
  track extra: -> { {coupon_id: params[:coupon_id]} }, only: [:other]

  def welcome
    mail
  end

  def other
    mail
  end
end
