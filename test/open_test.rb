require_relative "test_helper"

class OpenTest < Minitest::Test
  def test_default
    message = OpenMailer.welcome.deliver_now
    refute_body "open.gif", message
  end

  def test_basic
    message = OpenMailer.basic.deliver_now
    assert_body "open.gif", message
  end
end
