require_relative "test_helper"

class TokenTest < Minitest::Test
  def test_secret_token
    # ensure consistent across Rails releases
    expected = "0baf04b17695d9934775733e6941fcc0f024c68ee98d539dc0c214823fa0e255708ac74a4957cb561ddd8a63af9a24e1d255259d95306734fb513e5e7cbb897d"
    assert_equal expected, AhoyEmail.secret_token.first.unpack1("h*")
  end
end
