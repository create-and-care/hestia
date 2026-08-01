require "test_helper"

class Ui::AvatarGroupComponentTest < ViewComponent::TestCase
  test "renders one avatar per member with an overlapping stack" do
    render_inline(Ui::AvatarGroupComponent.new(members: [ { alt: "Jane Doe" }, { alt: "John Doe" } ]))

    assert_selector ".-space-x-2\\.5"
    assert_selector "span", text: "JD", exact_text: true, count: 2
  end

  test "reveals each member's label via a tooltip" do
    render_inline(Ui::AvatarGroupComponent.new(members: [ { alt: "Jane Doe", label: "Jane Doe — Admin" } ]))

    assert_selector "[data-controller='tooltip']", text: "Jane Doe — Admin"
  end

  test "caps visible avatars at max and shows a +N overflow badge" do
    members = (1..7).map { |i| { alt: "Member #{i}" } }
    render_inline(Ui::AvatarGroupComponent.new(members: members, max: 5))

    assert_selector "[data-controller='tooltip']", count: 5
    assert_selector "span", text: "+2"
  end

  test "omits the overflow badge when under the max" do
    render_inline(Ui::AvatarGroupComponent.new(members: [ { alt: "Jane Doe" } ], max: 5))

    assert_no_text "+"
  end
end
