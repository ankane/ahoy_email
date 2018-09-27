class ExtraMailer < ApplicationMailer
  track extra: {coupon_id: 1}, only: [:basic]
  track extra: -> { {coupon_id: @coupon_id} }, only: [:other]

  def welcome
    mail
  end

  def basic
    mail
  end

  def other(coupon_id)
    @coupon_id = coupon_id
    mail
  end
end
