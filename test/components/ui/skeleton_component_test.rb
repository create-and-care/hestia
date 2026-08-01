require "test_helper"

class Ui::SkeletonComponentTest < ViewComponent::TestCase
  test "renders default skeleton classes" do
    render_inline(Ui::SkeletonComponent.new)

    assert_selector "div.bg-loader.rounded-md.h-4.w-full"
  end

  test "hides the placeholder from assistive tech" do
    render_inline(Ui::SkeletonComponent.new)

    assert_selector "div[aria-hidden='true']"
  end

  test "renders custom class_name" do
    render_inline(Ui::SkeletonComponent.new(class_name: "h-10 w-10 rounded-full"))

    assert_selector "div.bg-loader.h-10.w-10.rounded-full"
  end

  test "a custom radius class replaces the default instead of stacking with it" do
    render_inline(Ui::SkeletonComponent.new(class_name: "size-10 rounded-full"))

    refute_selector "div.rounded-md"
  end
end
