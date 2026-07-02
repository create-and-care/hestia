require "test_helper"

class TaskCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create" do
    assert_difference -> { households(:alpha).task_categories.count }, 1 do
      post task_categories_path, params: { task_category: { name: "Jardin" } }
    end
    assert_redirected_to tasks_path
  end

  test "destroy" do
    category = task_categories(:alpha_home)
    delete task_category_path(category)
    assert_redirected_to tasks_path
    assert_not TaskCategory.exists?(category.id)
  end
end
