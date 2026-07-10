require "test_helper"

class Ui::AvatarComponentTest < ViewComponent::TestCase
  test "renders derived fallback initials when no src or fallback given" do
    render_inline(Ui::AvatarComponent.new(alt: "John Doe"))

    assert_selector "span", text: "JD"
    assert_no_selector "img"
  end

  test "renders a custom fallback when provided" do
    render_inline(Ui::AvatarComponent.new(alt: "John Doe", fallback: "XX"))

    assert_selector "span", text: "XX"
  end

  test "renders an image when src is present" do
    render_inline(Ui::AvatarComponent.new(src: "https://example.com/avatar.jpg", alt: "John Doe"))

    assert_selector "img.size-full[src='https://example.com/avatar.jpg'][alt='John Doe']"
    assert_no_text "JD"
  end

  test "renders every size with its distinguishing class" do
    Ui::AvatarComponent::SIZES.each_key do |size|
      render_inline(Ui::AvatarComponent.new(alt: "AB", size: size))

      fragment = Ui::AvatarComponent::SIZES.fetch(size).split.first
      assert_selector "span.#{fragment}"
    end
  end
end
