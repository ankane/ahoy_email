require_relative "test_helper"

class TokenTest < Minitest::Test
  def test_secret_token
    # ensure consistent across Rails releases
    expected = "7f6a02c3632c8f46c90886517bc28c9bb67fc5634afa109cdb1e385592b9b91023bf4de7e2d074a8cd24c1ac0299d1b05837474212ec0cb104ec18659d71490b"
    assert_equal expected, AhoyEmail.secret_token.unpack1("h*")
  end

  def test_digest_class
    digest_class = Combustion::Application.key_generator.instance_variable_get(:@key_generator).instance_variable_get(:@hash_digest_class)
    assert_equal OpenSSL::Digest::SHA256, digest_class, "Digest class is different from what is configured in the Combustion application"
  end
end
