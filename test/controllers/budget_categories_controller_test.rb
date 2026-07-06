require "test_helper"

class BudgetCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post budget_categories_path, params: { budget_category: { kind: "expense", name: "Courses" } }
    assert_redirected_to new_session_path
  end

  test "create adds a category to the household" do
    assert_difference -> { households(:alpha).budget_categories.count }, 1 do
      post budget_categories_path, params: { budget_category: { kind: "expense", name: "Courses" } }
    end
    assert_redirected_to budget_path
  end

  test "create with an invalid kind does not persist" do
    assert_no_difference -> { BudgetCategory.count } do
      post budget_categories_path, params: { budget_category: { kind: "invalid", name: "Courses" } }
    end
    assert_redirected_to budget_path
  end

  test "destroy" do
    category = budget_categories(:alpha_rent)
    delete budget_category_path(category)
    assert_redirected_to budget_path
    assert_not BudgetCategory.exists?(category.id)
  end

  test "cannot destroy another household's category" do
    delete budget_category_path(budget_categories(:beta_cat))
    assert_response :not_found
  end
end
