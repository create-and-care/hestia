require "test_helper"

class BudgetControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get budget_path
    assert_redirected_to new_session_path
  end

  test "show renders the dashboard" do
    get budget_path
    assert_response :success
    assert_includes @response.body, "Salaire"
  end

  test "show renders a document count for a category with linked documents" do
    document = households(:alpha).documents.build(name: "Bail", documentable: budget_categories(:alpha_rent))
    document.file.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")), filename: "sample.pdf", content_type: "application/pdf")
    document.save!

    get budget_path
    assert_response :success
    assert_body_includes I18n.t("budget.show.documents_count", count: 1)
  end

  test "create a category" do
    assert_difference -> { households(:alpha).budget_categories.count }, 1 do
      post budget_categories_path, params: { budget_category: { kind: "expense", name: "Courses" } }
    end
    assert_redirected_to budget_path
  end

  test "create an entry under a household category" do
    assert_difference -> { budget_categories(:alpha_rent).budget_entries.count }, 1 do
      post budget_entries_path, params: { budget_entry: { budget_category_id: budget_categories(:alpha_rent).id, amount: 50, periodicity: "monthly" } }
    end
    assert_redirected_to budget_path
  end

  test "cannot add an entry to another household's category" do
    assert_no_difference -> { BudgetEntry.count } do
      post budget_entries_path, params: { budget_entry: { budget_category_id: budget_categories(:beta_cat).id, amount: 50 } }
    end
    assert_response :not_found
  end

  test "create a savings envelope" do
    assert_difference -> { households(:alpha).savings_envelopes.count }, 1 do
      post savings_envelopes_path, params: { savings_envelope: { name: "Travaux", recurring_deposit: 100 } }
    end
    assert_redirected_to budget_path
  end

  test "no longer offers an emoji input in the new-category form" do
    get budget_path
    assert_response :success
    assert_select "input[name='budget_category[emoji]']", count: 0
  end
end
