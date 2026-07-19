require "test_helper"

class PoolTest < ActiveSupport::TestCase
  test "requires a name" do
    pool = Pool.new(household: households(:alpha), treatment_type: "sel")
    assert_not pool.valid?
    assert_includes pool.errors[:name], "can't be blank"
  end

  test "requires a treatment_type from the allowed list" do
    pool = Pool.new(household: households(:alpha), name: "Spa", treatment_type: "eau_de_javel")
    assert_not pool.valid?
    assert_includes pool.errors[:treatment_type], "is not included in the list"
  end

  test "accepts each allowed treatment_type" do
    Pool::TREATMENT_TYPES.each do |type|
      pool = Pool.new(household: households(:alpha), name: "Spa", treatment_type: type)
      assert pool.valid?, "expected #{type} to be valid, got #{pool.errors.full_messages}"
    end
  end

  test "destroying a pool destroys its readings and actions" do
    pool = pools(:alpha_pool)
    pool.pool_readings.create!(measure_type: "pH", value: 7.2, measured_on: Date.current)
    pool.pool_actions.create!(action_type: "hivernage", done_on: Date.current)

    assert_difference -> { PoolReading.count }, -1 do
      assert_difference -> { PoolAction.count }, -1 do
        pool.destroy
      end
    end
  end

  test "ordered sorts by name" do
    Pool.where(household: households(:alpha)).destroy_all
    b = Pool.create!(household: households(:alpha), name: "Zoo", treatment_type: "sel")
    a = Pool.create!(household: households(:alpha), name: "Alpha", treatment_type: "sel")
    assert_equal [ a, b ], Pool.where(household: households(:alpha)).ordered.to_a
  end

  test "service_provider is optional" do
    pool = Pool.new(household: households(:alpha), name: "Spa", treatment_type: "sel")
    assert pool.valid?
  end

  test "rejects a service_provider from another household" do
    pool = Pool.new(household: households(:alpha), name: "Spa", treatment_type: "sel",
      service_provider: service_providers(:beta_provider))
    assert_not pool.valid?
    assert_includes pool.errors[:service_provider], "is invalid"
  end

  test "measure_types depends on treatment_type" do
    assert_equal %w[pH temperature chlore_libre], Pool.new(treatment_type: "chlore").measure_types
    assert_equal %w[pH temperature taux_sel], Pool.new(treatment_type: "sel").measure_types
    assert_equal %w[pH temperature], Pool.new(treatment_type: "uv").measure_types
  end
end
