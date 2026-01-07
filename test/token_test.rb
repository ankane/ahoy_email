require_relative "test_helper"

class TokenTest < Minitest::Test
  def test_secret_token
    # ensure consistent across Rails releases
    expected = "0baf04b17695d9934775733e6941fcc0f024c68ee98d539dc0c214823fa0e255708ac74a4957cb561ddd8a63af9a24e1d255259d95306734fb513e5e7cbb897d"
    assert_equal expected, AhoyEmail.secret_token.unpack1("h*")
  end

  def test_digest_class
    digest_class = Combustion::Application.key_generator.instance_variable_get(:@key_generator).instance_variable_get(:@hash_digest_class)
    assert_equal OpenSSL::Digest::SHA256, digest_class, "Digest class is different from what is configured in the Combustion application"
  end
end
