require_relative "test_helper"

class InheritanceTest < Minitest::Test
  def test_parent
    ParentMailer.welcome.deliver_now
    refute_nil ahoy_message
  end

  def test_child
    ChildMailer.welcome.deliver_now
    refute_nil ahoy_message
  end

  def test_override
    ChildMailer.other.deliver_now
    assert_nil ahoy_message

    ParentMailer.other.deliver_now
    refute_nil ahoy_message
  end
end
