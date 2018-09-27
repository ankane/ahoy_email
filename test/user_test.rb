require_relative "test_helper"

class UserTest < Minitest::Test
  def setup
    super
    User.delete_all
  end

  def test_no_user
    UserMailer.welcome.deliver_now
    assert_nil ahoy_message.user
  end

  def test_params_user
    skip unless params_supported?
    user = User.create!
    UserMailer.with(user: user).welcome.deliver_now
    assert_equal user, ahoy_message.user
  end

  def test_to
    user = User.create!(email: "test@example.org")
    UserMailer.to_field(user.email).deliver_now
    assert_equal user, ahoy_message.user
  end

  def test_dynamic
    user = User.create!
    UserMailer.dynamic(user).deliver_now
    assert_equal user, ahoy_message.user
  end
end
