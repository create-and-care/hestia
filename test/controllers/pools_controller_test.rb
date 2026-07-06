require "test_helper"

class PoolsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post pools_path, params: { pool: { name: "Spa", treatment_type: "brome" } }
    assert_redirected_to new_session_path
  end

  test "create adds a pool to the current household" do
    assert_difference -> { households(:alpha).pools.count }, 1 do
      post pools_path, params: { pool: { name: "Spa", treatment_type: "brome" } }
    end
    assert_redirected_to exterior_path
  end

  test "destroy" do
    pool = pools(:alpha_pool)
    delete pool_path(pool)
    assert_redirected_to exterior_path
    assert_not Pool.exists?(pool.id)
  end

  test "cannot destroy another household's pool" do
    assert_no_difference -> { Pool.count } do
      delete pool_path(pools(:beta_pool))
    end
    assert_response :not_found
  end
end
