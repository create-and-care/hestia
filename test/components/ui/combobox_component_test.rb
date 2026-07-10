require "test_helper"

class Ui::ComboboxComponentTest < ViewComponent::TestCase
  OPTIONS = [ [ "Apple", "apple" ], [ "Banana", "banana" ], [ "Cherry", "cherry" ] ].freeze

  test "renders default with placeholder label and hidden input" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "div[data-controller='combobox']"
    assert_selector "input[type='hidden'][name='fruit'][data-combobox-target='input']", visible: :all
    assert_selector "span[data-combobox-target='label']", text: "Select an option"
  end

  test "renders a custom placeholder" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS, placeholder: "Pick a fruit"))

    assert_selector "span[data-combobox-target='label']", text: "Pick a fruit"
  end

  test "shows the label of the selected option" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS, selected: "banana"))

    assert_selector "span[data-combobox-target='label']", text: "Banana"
    assert_selector "input[data-combobox-target='input'][value='banana']", visible: :all
  end

  test "renders an item button per option with value and label data" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "button[data-combobox-target='item']", count: 3, visible: :all
    assert_selector "button[data-combobox-target='item'][data-value='banana'][data-label='Banana']", text: "Banana", visible: :all
  end

  test "renders a search input and an empty state (hidden by default)" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "input[data-combobox-target='search'][data-action*='input->combobox#filter']", visible: :all
    assert_selector "p[data-combobox-target='empty'][hidden]", text: "No results found.", visible: :all
  end

  test "panel starts hidden and closed" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "div[data-combobox-target='panel'][hidden][data-state='closed']", visible: :all
  end

  test "trigger exposes listbox popup semantics wired to the listbox" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS))

    trigger = page.find("button[data-combobox-target='trigger']")
    listbox = page.find("div[role='listbox']", visible: :all)

    assert_equal "listbox", trigger["aria-haspopup"]
    assert_equal "false", trigger["aria-expanded"]
    assert_equal listbox[:id], trigger["aria-controls"]
  end

  test "items have role=option and are not individually focusable" do
    render_inline(Ui::ComboboxComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "button[role='option'][tabindex='-1'][data-combobox-target='item']", count: 3, visible: :all
  end
end
