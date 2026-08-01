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

  test "tints with an explicit module key" do
    render_inline(Ui::AvatarComponent.new(alt: "John Doe", tint: :budget))

    assert_selector "span.bg-module-budget\\/14.text-module-budget"
  end

  test "hashes into the 12-module pool when no tint is given" do
    render_inline(Ui::AvatarComponent.new(alt: "John Doe"))

    expected_key = Ui::AvatarComponent::MODULES["JD".sum % Ui::AvatarComponent::MODULES.size]
    assert_selector "span.bg-module-#{expected_key}\\/14.text-module-#{expected_key}"
  end

  test "applies a raw CSS color tint via inline style, not a Tailwind class" do
    render_inline(Ui::AvatarComponent.new(alt: "John Doe", tint: "#A85030"))

    assert_selector "span[style*='#A85030']"
    Ui::AvatarComponent::MODULE_TINTS.values.each do |classes|
      assert_no_selector "span.#{classes.split.first.sub("/", "\\/")}"
    end
  end

  test "the +N overflow avatar never applies a tint" do
    render_inline(Ui::AvatarComponent.new(fallback: "+3", tint: :budget))

    assert_selector "span.bg-surface-inset.text-secondary"
    assert_no_selector "span.bg-module-budget\\/14"
  end
end
