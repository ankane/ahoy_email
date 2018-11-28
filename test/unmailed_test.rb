require_relative "test_helper"

class UnmailedTest < Minitest::Test
  def test_unmailed
    UnmailedMailer.hello.deliver_now
    assert_nil ahoy_message
  end
end
