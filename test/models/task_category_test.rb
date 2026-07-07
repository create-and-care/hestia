require "test_helper"

class TaskCategoryTest < ActiveSupport::TestCase
  test "requires a name" do
    category = households(:alpha).task_categories.build
    assert_not category.valid?
    category.name = "Cuisine"
    assert category.valid?
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).task_categories, task_categories(:beta_work)
  end

  test "destroying a category nullifies its tasks" do
    category = task_categories(:alpha_home)
    task = tasks(:alpha_dishes)
    assert_equal category.id, task.task_category_id
    category.destroy
    assert_nil task.reload.task_category_id
  end
end
