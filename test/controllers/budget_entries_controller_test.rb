require "test_helper"

class BudgetEntriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post budget_entries_path, params: { budget_entry: { budget_category_id: budget_categories(:alpha_rent).id, amount: 50, periodicity: "monthly" } }
    assert_redirected_to new_session_path
  end

  test "create adds an entry to a household category" do
    assert_difference -> { budget_categories(:alpha_rent).budget_entries.count }, 1 do
      post budget_entries_path, params: { budget_entry: { budget_category_id: budget_categories(:alpha_rent).id, name: "Internet", amount: 40, periodicity: "monthly" } }
    end
    assert_redirected_to budget_path
  end

  test "create rejects a budget category from another household" do
    assert_no_difference -> { BudgetEntry.count } do
      post budget_entries_path, params: { budget_entry: { budget_category_id: budget_categories(:beta_cat).id, amount: 50, periodicity: "monthly" } }
    end
    assert_response :not_found
  end

  test "destroy" do
    entry = budget_entries(:rent_entry)
    delete budget_entry_path(entry)
    assert_redirected_to budget_path
    assert_not BudgetEntry.exists?(entry.id)
  end

  test "cannot destroy another household's entry" do
    delete budget_entry_path(budget_entries(:beta_entry))
    assert_response :not_found
  end
end
