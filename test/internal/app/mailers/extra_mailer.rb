class ExtraMailer < ApplicationMailer
  track extra: {coupon_id: 1}, only: [:basic]
  track extra: -> { {coupon_id: params[:coupon_id]} }, only: [:other]
  track extra: -> { {coupon_id: @coupon_id} }, only: [:other_no_params]

  def welcome
    mail
  end

  def basic
    mail
  end

  def other
    mail
  end

  def other_no_params(coupon_id)
    @coupon_id = coupon_id
    mail
  end
end
