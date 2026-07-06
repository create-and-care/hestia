require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "switches to French" do
    patch locale_path, params: { locale: "fr" }
    assert_redirected_to root_path
    assert_equal "fr", users(:one).reload.locale
  end

  test "switches back to English" do
    users(:one).update!(locale: "fr")
    patch locale_path, params: { locale: "en" }
    assert_equal "en", users(:one).reload.locale
  end

  test "ignores an unknown locale" do
    users(:one).update!(locale: "en")
    patch locale_path, params: { locale: "de" }
    assert_equal "en", users(:one).reload.locale
  end

  test "redirects back to the referring page" do
    patch locale_path, params: { locale: "fr" }, headers: { "HTTP_REFERER" => "/exterior" }
    assert_redirected_to "/exterior"
  end
end
