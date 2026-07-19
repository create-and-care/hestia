require "test_helper"

class PoolReadingsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post pool_pool_readings_path(pools(:alpha_pool)), params: { pool_reading: { measure_type: "pH", value: 7.2, measured_on: Date.current } }
    assert_redirected_to new_session_path
  end

  test "create adds a reading to the household's pool" do
    pool = pools(:alpha_pool)
    assert_difference -> { pool.pool_readings.count }, 1 do
      post pool_pool_readings_path(pool), params: { pool_reading: { measure_type: "pH", value: 7.2, measured_on: Date.current } }
    end
    assert_redirected_to exterior_path
  end

  test "destroy" do
    pool = pools(:alpha_pool)
    reading = pool.pool_readings.create!(measure_type: "pH", value: 7.2, measured_on: Date.current)
    delete pool_pool_reading_path(pool, reading)
    assert_redirected_to exterior_path
    assert_not PoolReading.exists?(reading.id)
  end

  test "create with a measure_type unrelated to the pool's treatment redirects with an error" do
    pool = pools(:alpha_pool) # sel
    assert_no_difference -> { PoolReading.count } do
      post pool_pool_readings_path(pool), params: { pool_reading: { measure_type: "chlore_libre", value: 1, measured_on: Date.current } }
    end
    assert_redirected_to exterior_path
    assert_not_nil flash[:alert]
  end

  test "cannot add a reading to another household's pool" do
    assert_no_difference -> { PoolReading.count } do
      post pool_pool_readings_path(pools(:beta_pool)), params: { pool_reading: { measure_type: "pH", value: 7 } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's pool reading" do
    beta_reading = pools(:beta_pool).pool_readings.create!(measure_type: "pH", value: 7.0, measured_on: Date.current)
    assert_no_difference -> { PoolReading.count } do
      delete pool_pool_reading_path(pools(:beta_pool), beta_reading)
    end
    assert_response :not_found
  end
end
