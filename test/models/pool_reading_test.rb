require "test_helper"

class PoolReadingTest < ActiveSupport::TestCase
  test "requires measured_on and measure_type" do
    reading = PoolReading.new(pool: pools(:alpha_pool))
    assert_not reading.valid?
    assert_includes reading.errors[:measured_on], "can't be blank"
    assert_includes reading.errors[:measure_type], "can't be blank"
  end

  test "belongs to a pool" do
    reading = PoolReading.new(measure_type: "pH", value: 7.2, measured_on: Date.current)
    assert_not reading.valid?
    assert_includes reading.errors[:pool], "must exist"
  end

  test "recent orders by measured_on then created_at, most recent first" do
    pool = pools(:alpha_pool)
    older = pool.pool_readings.create!(measure_type: "pH", value: 7.0, measured_on: 2.days.ago.to_date)
    newer = pool.pool_readings.create!(measure_type: "pH", value: 7.4, measured_on: Date.current)

    assert_equal [ newer, older ], pool.pool_readings.recent.to_a
  end

  test "measure_type must be relevant to the pool's treatment_type" do
    pool = pools(:alpha_pool) # sel
    reading = pool.pool_readings.new(measure_type: "chlore_libre", value: 1, measured_on: Date.current)
    assert_not reading.valid?
    assert_includes reading.errors[:measure_type], "is not included in the list"
  end

  test "accepts a measure_type relevant to the pool's treatment_type" do
    pool = pools(:alpha_pool) # sel
    reading = pool.pool_readings.new(measure_type: "taux_sel", value: 3, measured_on: Date.current)
    assert reading.valid?
  end
end
