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

  test "create with an invalid treatment_type redirects with an error instead of failing silently" do
    assert_no_difference -> { Pool.count } do
      post pools_path, params: { pool: { name: "Spa", treatment_type: "eau_de_javel" } }
    end
    assert_redirected_to exterior_path
    assert_not_nil flash[:alert]
  end

  test "edit" do
    get edit_pool_path(pools(:alpha_pool))
    assert_response :success
  end

  test "cannot edit another household's pool" do
    get edit_pool_path(pools(:beta_pool))
    assert_response :not_found
  end

  test "update" do
    pool = pools(:alpha_pool)
    patch pool_path(pool), params: { pool: { name: "Piscine rénovée" } }
    assert_redirected_to exterior_path
    assert_equal "Piscine rénovée", pool.reload.name
  end

  test "update can link a service provider from the same household" do
    pool = pools(:alpha_pool)
    patch pool_path(pool), params: { pool: { service_provider_id: service_providers(:alpha_plombier).id } }
    assert_equal service_providers(:alpha_plombier), pool.reload.service_provider
  end

  test "update rejects a service provider from another household" do
    pool = pools(:alpha_pool)
    patch pool_path(pool), params: { pool: { service_provider_id: service_providers(:beta_provider).id } }
    assert_response :unprocessable_entity
    assert_nil pool.reload.service_provider
  end

  test "update with an invalid treatment_type re-renders the edit form" do
    pool = pools(:alpha_pool)
    patch pool_path(pool), params: { pool: { treatment_type: "eau_de_javel" } }
    assert_response :unprocessable_entity
    assert_equal "sel", pool.reload.treatment_type
  end

  test "cannot update another household's pool" do
    patch pool_path(pools(:beta_pool)), params: { pool: { name: "X" } }
    assert_response :not_found
  end

  test "history paginates readings and actions and renders trend charts" do
    pool = pools(:alpha_pool)
    12.times { |i| pool.pool_readings.create!(measure_type: "pH", value: 7.0 + i * 0.01, measured_on: i.days.ago.to_date) }

    get history_pool_path(pool)

    assert_response :success
    assert_includes @response.body, "pH"
  end

  test "cannot view another household's pool history" do
    get history_pool_path(pools(:beta_pool))
    assert_response :not_found
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
