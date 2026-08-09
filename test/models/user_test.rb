require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "rejects a password shorter than 8 characters" do
    user = User.new(name: "Test", email_address: "short_pw@example.com", password: "short", password_confirmation: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], error_message(:too_short, count: 8)
  end

  test "accepts a password of 8 characters or more" do
    user = User.new(name: "Test", email_address: "long_pw@example.com", password: "longenough", password_confirmation: "longenough")
    assert user.valid?
  end

  test "does not require a password length check when the password is untouched" do
    user = users(:one)
    user.name = "Renamed"
    assert user.valid?
  end

  test "normalizes blank avatar_tint to nil" do
    user = User.new(name: "Test", email_address: "test@example.com", password: "password123", avatar_tint: "")
    assert_nil user.avatar_tint

    user.avatar_tint = "   "
    assert_nil user.avatar_tint
  end

  test "accepts every stringified MODULES entry as a valid avatar_tint" do
    Ui::AvatarComponent::MODULES.each do |module_key|
      user = User.new(name: "Test", email_address: "test@example.com", password: "password123", avatar_tint: module_key.to_s)
      assert user.valid?, "Expected #{module_key.to_s} to be a valid avatar_tint, but validation failed: #{user.errors.full_messages}"
    end
  end

  test "rejects an invalid avatar_tint value" do
    user = User.new(name: "Test", email_address: "invalid@example.com", password: "password123", avatar_tint: "invalid_module")
    assert_not user.valid?
    assert_includes user.errors[:avatar_tint], error_message(:inclusion)
  end
end
