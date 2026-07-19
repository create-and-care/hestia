require "test_helper"

class PoolActionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post pool_pool_actions_path(pools(:alpha_pool)), params: { pool_action: { action_type: "hivernage", done_on: Date.current } }
    assert_redirected_to new_session_path
  end

  test "create adds an action to the household's pool" do
    pool = pools(:alpha_pool)
    assert_difference -> { pool.pool_actions.count }, 1 do
      post pool_pool_actions_path(pool), params: { pool_action: { action_type: "hivernage", done_on: Date.current, note: "RAS" } }
    end
    assert_redirected_to exterior_path
  end

  test "destroy" do
    pool = pools(:alpha_pool)
    action = pool.pool_actions.create!(action_type: "hivernage", done_on: Date.current)
    delete pool_pool_action_path(pool, action)
    assert_redirected_to exterior_path
    assert_not PoolAction.exists?(action.id)
  end

  test "create with a blank action_type redirects with an error instead of failing silently" do
    pool = pools(:alpha_pool)
    assert_no_difference -> { PoolAction.count } do
      post pool_pool_actions_path(pool), params: { pool_action: { action_type: "", done_on: Date.current } }
    end
    assert_redirected_to exterior_path
    assert_not_nil flash[:alert]
  end

  test "cannot add an action to another household's pool" do
    assert_no_difference -> { PoolAction.count } do
      post pool_pool_actions_path(pools(:beta_pool)), params: { pool_action: { action_type: "hivernage", done_on: Date.current } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's pool action" do
    beta_action = pools(:beta_pool).pool_actions.create!(action_type: "hivernage", done_on: Date.current)
    assert_no_difference -> { PoolAction.count } do
      delete pool_pool_action_path(pools(:beta_pool), beta_action)
    end
    assert_response :not_found
  end
end
