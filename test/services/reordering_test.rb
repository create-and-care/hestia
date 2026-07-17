require "test_helper"

class ReorderingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "applies the given order to the position column" do
    list = shopping_lists(:alpha_groceries)
    apples = shopping_list_items(:alpha_apples)
    bread = shopping_list_items(:alpha_bread)

    Reordering.apply(list.items, [ bread.id, apples.id ])

    assert_equal 0, bread.reload.position
    assert_equal 1, apples.reload.position
  end

  test "broadcasts the change instead of silently skipping callbacks" do
    list = shopping_lists(:alpha_groceries)
    apples = shopping_list_items(:alpha_apples)
    bread = shopping_list_items(:alpha_bread)

    assert_enqueued_with(job: Turbo::Streams::ActionBroadcastJob) do
      Reordering.apply(list.items, [ bread.id, apples.id ])
    end
  end

  test "ignores unknown ids" do
    list = shopping_lists(:alpha_groceries)
    apples = shopping_list_items(:alpha_apples)

    assert_nothing_raised do
      Reordering.apply(list.items, [ apples.id, "not-an-id" ])
    end
  end
end
