require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test "generates a plaintext token only available right after creation" do
    token = ApiToken.create!(user: users(:one), name: "Test")
    assert token.plaintext_token.present?
    assert_not_equal token.plaintext_token, token.token_digest
  end

  test "authenticate finds the token by its plaintext value" do
    token = ApiToken.create!(user: users(:one), name: "Test")
    found = ApiToken.authenticate(token.plaintext_token)
    assert_equal token, found
  end

  test "authenticate returns nil for a wrong or blank token" do
    ApiToken.create!(user: users(:one), name: "Test")
    assert_nil ApiToken.authenticate("wrong-token")
    assert_nil ApiToken.authenticate("")
    assert_nil ApiToken.authenticate(nil)
  end

  test "touch_last_used! updates last_used_at" do
    token = ApiToken.create!(user: users(:one), name: "Test")
    assert_nil token.last_used_at

    token.touch_last_used!
    assert token.reload.last_used_at.present?
  end
end
