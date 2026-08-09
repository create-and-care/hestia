require "application_system_test_case"

class MenuTest < ApplicationSystemTestCase
  test "day cards collapse by default except today, and expand on click" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    visit menu_path

    other_day = (Date.current.beginning_of_week..Date.current.beginning_of_week + 6.days).find { |d| d != Date.current }

    assert_selector "#menu_day_#{Date.current.iso8601}-panel"
    assert_no_selector "#menu_day_#{other_day.iso8601}-panel"
    assert_selector "#menu_day_#{other_day.iso8601}-panel", visible: :all

    # A plain Capybara click on this custom Stimulus-driven trigger is flaky
    # here for the same reason noted in global_search_test.rb/recipe_catalog_test.rb:
    # dispatch it via JS instead.
    trigger = find("button[aria-controls='menu_day_#{other_day.iso8601}-panel']")
    click_element(trigger)
    assert_selector "#menu_day_#{other_day.iso8601}-panel"
  end

  test "adding a meal, marking it away, then deleting it shows the design-system alert confirmations" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    visit menu_path

    within "#menu_day_#{Date.current.iso8601}-panel" do
      click_element(find(:button, "Add a meal"))
    end
    assert_dialog_open
    fill_in "meal_plan_entry[free_name]", with: "Salade César"
    submit_button_to "Add"
    assert_text "Salade César"

    within "#menu_day_#{Date.current.iso8601}-panel" do
      click_element(find(:button, "Add a meal"))
    end
    assert_dialog_open
    submit_button_to "Away"

    # "Away" is also the label of the button that just submitted this form, so
    # assert_text matches the dialog still fading out and passes before the
    # entry exists at all — find_by! below then loses the race and blows up
    # with RecordNotFound. The day's list only grows an <li> for it once the
    # server has actually created it.
    assert_selector "li", text: "Away"

    entry = MealPlanEntry.find_by!(away: true)
    within "li", text: "Away" do
      click_element(find("[aria-label='Edit meal']"))
    end
    assert_dialog_open
    within "dialog[data-state='open']" do
      click_element(find("[aria-label='Close']", visible: :all))
    end

    within "li", text: "Away" do
      click_element(find("[aria-label='Delete meal']"))
    end
    assert_dialog_open "dialog[role='alertdialog'][data-state='open']"
    submit_button_to "Delete"

    assert_text "Meal deleted."
    assert_not MealPlanEntry.exists?(entry.id)
  end

  test "add ingredients dialog flags recipes already exported with an alert and a link to the list" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    Recipes::AddIngredientsToShoppingList.call(recipe: recipes(:alpha_pancakes), shopping_list: shopping_lists(:alpha_groceries))

    visit menu_path

    click_element(find(:button, "Add ingredients to shopping list"))
    assert_dialog_open
    submit_button_to "Add to this list"

    assert_text "This week's recipes were already added to the shopping list."
    assert_selector "a", text: "View shopping list"
  end
end
