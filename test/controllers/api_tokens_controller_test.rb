require "test_helper"

class ApiTokensControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get api_tokens_path
    assert_redirected_to new_session_path
  end

  test "create issues a token and shows its plaintext value once" do
    assert_difference -> { users(:one).api_tokens.count }, 1 do
      post api_tokens_path, params: { api_token: { name: "iPhone" } }
    end
    assert_redirected_to api_tokens_path
    follow_redirect!
    assert_match(/Token iPhone created/, @response.body)
  end

  test "destroy cannot reach another user's token" do
    other_token = ApiToken.create!(user: users(:two), name: "Other")

    delete api_token_path(other_token)

    assert_response :not_found
    assert ApiToken.exists?(other_token.id)
  end
end
