require "test_helper"

class PoolActionTest < ActiveSupport::TestCase
  test "requires done_on and action_type" do
    action = PoolAction.new(pool: pools(:alpha_pool))
    assert_not action.valid?
    assert_includes action.errors[:done_on], "can't be blank"
    assert_includes action.errors[:action_type], "can't be blank"
  end

  test "belongs to a pool" do
    action = PoolAction.new(action_type: "hivernage", done_on: Date.current)
    assert_not action.valid?
    assert_includes action.errors[:pool], "must exist"
  end

  test "recent orders by done_on then created_at, most recent first" do
    pool = pools(:alpha_pool)
    older = pool.pool_actions.create!(action_type: "hivernage", done_on: 2.days.ago.to_date)
    newer = pool.pool_actions.create!(action_type: "nettoyage_filtre", done_on: Date.current)

    assert_equal [ newer, older ], pool.pool_actions.recent.to_a
  end
end
