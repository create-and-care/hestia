require "test_helper"

class Ui::CommandComponentTest < ViewComponent::TestCase
  GROUPS = [
    [ "Suggestions", [ [ "Calendar", "calendar" ], [ "Search", "search" ] ] ],
    [ "Settings", [ [ "Profile", "profile" ] ] ]
  ].freeze

  test "renders default input with placeholder" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS))

    assert_selector "div[data-controller='command']"
    assert_selector "input[data-command-target='input'][placeholder='Type a command or search…']"
  end

  test "renders a custom placeholder" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS, placeholder: "Search commands..."))

    assert_selector "input[data-command-target='input'][placeholder='Search commands...']"
  end

  test "renders group labels and items" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS))

    assert_selector "p", text: "Suggestions"
    assert_selector "p", text: "Settings"
    assert_selector "button[data-command-target='item'][data-value='calendar']", text: "Calendar"
    assert_selector "button[data-command-target='item'][data-value='search']", text: "Search"
    assert_selector "button[data-command-target='item'][data-value='profile']", text: "Profile"
    assert_selector "button[data-command-target='item']", count: 3
  end

  test "select action is wired on items" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS))

    assert_selector "button[data-action='click->command#select']", count: 3
  end

  test "renders an empty state hidden by default" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS))

    assert_selector "p[data-command-target='empty'][hidden]", text: "No results found.", visible: :all
  end

  test "renders no groups when groups is empty" do
    render_inline(Ui::CommandComponent.new(groups: []))

    refute_selector "button[data-command-target='item']"
  end

  test "input has combobox role wired to the listbox via aria-controls" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS))

    input = page.find("input[data-command-target='input']")
    listbox = page.find("[role='listbox']")

    assert_equal "combobox", input["role"]
    assert_equal "true", input["aria-expanded"]
    assert_equal listbox["id"], input["aria-controls"]
  end

  test "items expose stable ids as role=option for aria-activedescendant" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS))

    ids = page.all("[data-command-target='item']", visible: :all).map { |el| el["id"] }

    assert_equal 3, ids.compact.uniq.size
    assert_selector "button[data-command-target='item'][role='option']", count: 3
  end

  test "keydown navigation is wired on the input" do
    render_inline(Ui::CommandComponent.new(groups: GROUPS))

    assert_selector "input[data-action='input->command#filter keydown->command#onKeydown']"
  end
end
