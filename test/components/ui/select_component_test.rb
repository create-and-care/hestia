require "test_helper"

class Ui::SelectComponentTest < ViewComponent::TestCase
  OPTIONS = [ [ "Apple", "apple" ], [ "Banana", "banana" ], [ "Cherry", "cherry" ] ].freeze

  test "renders default with placeholder label and hidden input" do
    render_inline(Ui::SelectComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "div[data-controller='select']"
    assert_selector "input[type='hidden'][name='fruit'][data-select-target='input']", visible: :all
    assert_selector "span[data-select-target='label']", text: "Select an option"
  end

  test "renders a custom placeholder" do
    render_inline(Ui::SelectComponent.new(name: "fruit", options: OPTIONS, placeholder: "Pick a fruit"))

    assert_selector "span[data-select-target='label']", text: "Pick a fruit"
  end

  test "shows the label of the selected option and marks it aria-selected" do
    render_inline(Ui::SelectComponent.new(name: "fruit", options: OPTIONS, selected: "banana"))

    assert_selector "span[data-select-target='label']", text: "Banana"
    assert_selector "input[data-select-target='input'][value='banana']", visible: :all
    assert_selector "button[role='option'][data-value='banana'][aria-selected='true']", visible: :all
    assert_selector "button[role='option'][data-value='apple'][aria-selected='false']", visible: :all
    assert_selector "button[role='option'][data-value='cherry'][aria-selected='false']", visible: :all
  end

  test "panel has listbox role and starts hidden and closed" do
    render_inline(Ui::SelectComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "div[data-select-target='panel'][role='listbox'][hidden][data-state='closed']", visible: :all
  end

  test "renders an option button per option" do
    render_inline(Ui::SelectComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "button[role='option'][data-select-target='item']", count: 3, visible: :all
    assert_selector "button[role='option'][data-value='apple'][data-label='Apple']", text: "Apple", visible: :all
  end

  test "trigger exposes listbox popup semantics wired to the panel" do
    render_inline(Ui::SelectComponent.new(name: "fruit", options: OPTIONS))

    trigger = page.find("button[data-select-target='trigger']")
    panel = page.find("div[data-select-target='panel']", visible: :all)

    assert_equal "listbox", trigger["aria-haspopup"]
    assert_equal "false", trigger["aria-expanded"]
    assert_equal panel[:id], trigger["aria-controls"]
  end

  test "options are not individually focusable (active-descendant pattern)" do
    render_inline(Ui::SelectComponent.new(name: "fruit", options: OPTIONS))

    assert_selector "button[role='option'][tabindex='-1']", count: 3, visible: :all
  end
end
