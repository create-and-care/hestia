require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get search_path
    assert_redirected_to new_session_path
  end

  test "renders the hint state when the query is blank" do
    get search_path
    assert_response :success
    assert_select "turbo-frame#global_search_results"
    assert_includes @response.body, I18n.t("search.hint")
  end

  test "finds a matching record scoped to the household" do
    get search_path(q: "vaisselle")
    assert_response :success
    assert_includes @response.body, "Faire la vaisselle"
    assert_not_includes @response.body, "Rapport" # beta's task
  end

  test "renders the no-results state for a query matching nothing" do
    get search_path(q: "zzzznomatchzzzz")
    assert_response :success
    assert_includes @response.body, I18n.t("search.no_results")
  end
end
