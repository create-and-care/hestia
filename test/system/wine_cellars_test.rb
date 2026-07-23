require "application_system_test_case"

class WineCellarsTest < ApplicationSystemTestCase
  def sign_in_to_alpha
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name
  end

  test "creating a cellar via the modal" do
    sign_in_to_alpha
    visit wine_cellars_path

    page.execute_script("arguments[0].click()", find(:button, "Create cellar").native)
    assert_selector "dialog[data-state='open']"
    within "dialog[data-state='open']" do
      fill_in "wine_cellar_name", with: "Champagnes"
      submit_button_to "Create cellar"
    end

    assert_text "Champagnes"
  end

  test "filtering bottles by wine type shows only matching bottles" do
    sign_in_to_alpha
    visit wine_cellars_path

    page.execute_script("arguments[0].click()", find(:button, "Filters").native)
    assert_selector "dialog[data-state='open']"
    within "dialog[data-state='open']" do
      select "White", from: "wine_cellars_filter_wine_type"
      submit_button_to "Apply filters"
    end

    assert_text "Chardonnay Bourgogne"
    assert_no_text "Château Margaux"
  end

  test "deleting a bottle shows the design-system alert dialog" do
    sign_in_to_alpha
    bottle = bottles(:alpha_bordeaux)
    visit wine_cellars_path

    within "##{ActionView::RecordIdentifier.dom_id(bottle)}" do
      page.execute_script("arguments[0].click()", find("[aria-label='Delete \"#{bottle.name}\"']").native)
    end
    assert_selector "dialog[role='alertdialog'][data-state='open']"
    within "dialog[data-state='open']" do
      submit_button_to "Delete"
    end

    assert_no_text bottle.name
    assert_not Bottle.exists?(bottle.id)
  end

  test "taking a bottle out asks for confirmation before updating stock" do
    sign_in_to_alpha
    bottle = bottles(:alpha_bordeaux)
    visit wine_cellars_path

    within "##{ActionView::RecordIdentifier.dom_id(bottle)}" do
      page.execute_script("arguments[0].click()", find(:button, "Take out").native)
    end
    assert_selector "dialog[role='alertdialog'][data-state='open']"
    within "dialog[data-state='open']" do
      submit_button_to "Take out"
    end

    assert_text "Put back"
    assert_not bottle.reload.in_stock
  end

  test "adding a bottle with a brand-new region via the autocomplete field" do
    sign_in_to_alpha
    cellar = wine_cellars(:alpha_reds)
    visit wine_cellars_path

    within "##{ActionView::RecordIdentifier.dom_id(cellar)}" do
      fill_in "bottle_name_#{cellar.id}", with: "Saint-Émilion"
      find("[data-combobox-target='trigger']").click
      find("[data-combobox-target='search']").set("Pomerol")
      find("[data-combobox-target='createOption']").click
      click_on "Add"
    end

    assert_text "Saint-Émilion"
    assert_equal "Pomerol", Bottle.find_by!(name: "Saint-Émilion").region
  end
end
