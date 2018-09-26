require_relative "test_helper"

class UserMailer < ApplicationMailer
  track user: -> { params[:some_user] }, only: [:other]

  def welcome
    mail to: params[:email], subject: "Hello", body: "World"
  end

  def other
    mail to: params[:email], subject: "Hello", body: "World"
  end
end

class UserTest < Minitest::Test
  def test_no_user
    UserMailer.with(email: "test@example.org").welcome.deliver_now
    assert_nil ahoy_message.user
  end

  def test_params_user
    user = User.create!
    UserMailer.with(email: "test@example.org", user: user).welcome.deliver_now
    assert_equal user, ahoy_message.user
  end

  def test_to
    user = User.create!(email: "test@example.org")
    UserMailer.with(email: "test@example.org").welcome.deliver_now
    assert_equal user, ahoy_message.user
  end

  def test_proc
    user = User.create!
    UserMailer.with(email: "test@example.org", some_user: user).other.deliver_now
    assert_equal user, ahoy_message.user
  end
end
