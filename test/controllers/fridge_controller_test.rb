require "test_helper"

class FridgeControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get fridge_path
    assert_redirected_to new_session_path
  end

  test "shows the household's fridge and wires the real-time stream" do
    get fridge_path
    assert_response :success
    assert_select "turbo-cable-stream-source"
    assert_includes @response.body, "Yaourts"
    # Not a plain text check: alpha's own product catalog (shared with
    # Shopping) happens to also contain a product named "Lait", same as
    # beta's fridge item — so isolation is verified by DOM id instead.
    assert_select "##{dom_id(fridge_items(:beta_milk))}", false
  end

  test "search filters the items" do
    get fridge_path(q: "yaourt")
    assert_response :success
    assert_includes @response.body, "Yaourts"
    assert_not_includes @response.body, "Petits pois"
  end

  # What you can cook right now is a property of the fridge's contents, so it
  # belongs beside the control that narrows them.
  test "the recipe suggestions sit in the header next to the search field" do
    # A suggestion needs a fridge item whose name appears in a recipe ingredient.
    households(:alpha).fridge_items.create!(name: "farine", location: "garde_manger")

    get fridge_path
    assert_response :success
    assert_select "header" do
      assert_select "[data-controller='dialog'] button", minimum: 1
      assert_select "input#fridge_q"
    end
  end

  test "the add-food dialog is widened to hold its row of fields" do
    get fridge_path
    assert_response :success
    # Scoped to the add-food dialog: the item edit dialog is also :lg, so a bare
    # `dialog.max-w-2xl` would still pass if this one lost its size.
    assert_select "section [data-controller='dialog'] dialog.max-w-2xl" do
      assert_select "form[action=?]", fridge_items_path
    end
  end

  test "the edit control is a button rather than a text link" do
    get fridge_path
    assert_response :success
    assert_select "button.border", text: /#{Regexp.escape(I18n.t("fridge_items.fridge_item.edit"))}/
  end
end
