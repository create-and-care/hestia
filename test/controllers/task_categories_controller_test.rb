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
    tasks(:alpha_dishes).update!(done: true)
    delete task_category_path(category)
    assert_redirected_to tasks_path
    assert_not TaskCategory.exists?(category.id)
  end

  test "destroy is blocked when the category still has an undone task" do
    category = task_categories(:alpha_home)
    task = tasks(:alpha_dishes)
    assert_not task.done?

    delete task_category_path(category)

    assert_redirected_to tasks_path
    follow_redirect!
    assert_select "[data-flash-message-value=?]", I18n.t("task_categories.destroy.pending_tasks_alert")
    assert TaskCategory.exists?(category.id)
    assert_equal category.id, task.reload.task_category_id
  end
end
