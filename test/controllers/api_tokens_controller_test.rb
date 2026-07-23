require "test_helper"

class ApiTokensControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post api_tokens_path, params: { api_token: { name: "iPhone" } }
    assert_redirected_to new_session_path
  end

  test "create issues a token and shows its plaintext value once, with a copy button" do
    assert_difference -> { users(:one).api_tokens.count }, 1 do
      post api_tokens_path, params: { api_token: { name: "iPhone" } }
    end
    assert_redirected_to household_path(households(:alpha), tab: "api")
    follow_redirect!
    assert_match(/Token iPhone created/, @response.body)

    token_value = css_select("#new_api_token").first.text.strip
    assert_match(/\A[0-9a-f]{64}\z/, token_value)
    assert_select "button[data-controller=clipboard][data-clipboard-text-value=?]", token_value
  end

  test "create rejects a blank name" do
    assert_no_difference -> { users(:one).api_tokens.count } do
      post api_tokens_path, params: { api_token: { name: "" } }
    end
    assert_redirected_to household_path(households(:alpha), tab: "api")
  end

  test "destroy cannot reach another user's token" do
    other_token = ApiToken.create!(user: users(:two), name: "Other")

    delete api_token_path(other_token)

    assert_response :not_found
    assert ApiToken.exists?(other_token.id)
  end

  test "create with no expiration choice never expires" do
    post api_tokens_path, params: { api_token: { name: "iPhone", expires_in: "" } }
    assert_nil users(:one).api_tokens.find_by!(name: "iPhone").expires_at
  end

  test "create with a 30 day expiration sets expires_at" do
    post api_tokens_path, params: { api_token: { name: "iPhone", expires_in: "30" } }
    token = users(:one).api_tokens.find_by!(name: "iPhone")
    assert_in_delta 30.days.from_now, token.expires_at, 1.minute
  end
end
