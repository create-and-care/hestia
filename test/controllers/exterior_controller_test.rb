require "test_helper"

class ExteriorControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get exterior_path
    assert_redirected_to new_session_path
  end

  test "show lists the household's plants and pools only" do
    get exterior_path
    assert_response :success
    assert_includes @response.body, "Rosier"
    assert_includes @response.body, "Piscine principale"
    assert_not_includes @response.body, "Cactus"
    assert_not_includes @response.body, "Piscine Beta"
  end

  test "add and remove a plant" do
    assert_difference -> { households(:alpha).plants.count }, 1 do
      post plants_path, params: { plant: { name: "Basilic" } }
    end
    assert_redirected_to exterior_path
  end

  test "add a pool and a reading and an action" do
    assert_difference -> { households(:alpha).pools.count }, 1 do
      post pools_path, params: { pool: { name: "Spa", treatment_type: "brome" } }
    end
    pool = pools(:alpha_pool)
    post pool_pool_readings_path(pool), params: { pool_reading: { measure_type: "pH", value: 7.2, measured_on: Date.current } }
    post pool_pool_actions_path(pool), params: { pool_action: { action_type: "hivernage", done_on: Date.current } }
    assert_equal 1, pool.pool_readings.count
    assert_equal 1, pool.pool_actions.count
  end

  test "cannot add a reading to another household's pool" do
    assert_no_difference -> { PoolReading.count } do
      post pool_pool_readings_path(pools(:beta_pool)), params: { pool_reading: { measure_type: "pH", value: 7 } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's plant" do
    assert_no_difference -> { Plant.count } do
      delete plant_path(plants(:beta_plant))
    end
    assert_response :not_found
  end

  test "show hides the pool section when the household has turned the Pool switch off" do
    households(:alpha).update!(pool_enabled: false)

    get exterior_path

    assert_response :success
    assert_includes @response.body, "Rosier"
    assert_not_includes @response.body, "Piscine principale"
  end
end
