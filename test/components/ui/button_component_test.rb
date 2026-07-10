require "test_helper"

class Ui::ButtonComponentTest < ViewComponent::TestCase
  test "renders a default button" do
    render_inline(Ui::ButtonComponent.new) { "Click me" }

    assert_selector "button[type='button'].bg-button-primary", text: "Click me"
    assert_no_selector "button[disabled]"
  end

  test "renders every variant with a distinguishing class fragment" do
    Ui::ButtonComponent::VARIANTS.each_key do |variant|
      render_inline(Ui::ButtonComponent.new(variant: variant)) { "Button" }

      assert_selector "button", text: "Button"
      assert_selector "button", class: variant_fragment(variant)
    end
  end

  test "renders every size with a distinguishing class fragment" do
    Ui::ButtonComponent::SIZES.each_key do |size|
      render_inline(Ui::ButtonComponent.new(size: size)) { "Button" }

      fragment = Ui::ButtonComponent::SIZES.fetch(size).split.first
      assert_selector "button.#{fragment}"
    end
  end

  test "renders as a disabled button" do
    render_inline(Ui::ButtonComponent.new(disabled: true)) { "Disabled" }

    assert_selector "button[disabled]"
  end

  test "renders as a link when href is given, with content and classes intact" do
    render_inline(Ui::ButtonComponent.new(href: "/somewhere")) { "Go" }

    assert_selector "a[href='/somewhere'].bg-button-primary", text: "Go"
    assert_no_selector "button"
  end

  test "link mode merges html_options and custom classes" do
    render_inline(Ui::ButtonComponent.new(href: "/somewhere", html_options: { class: "extra-class", id: "my-link", data: { turbo: false } })) { "Go" }

    assert_selector "a#my-link.extra-class.bg-button-primary[href='/somewhere'][data-turbo='false']", text: "Go"
  end

  test "renders custom type and merges html_options" do
    render_inline(Ui::ButtonComponent.new(type: "submit", html_options: { class: "extra-class", id: "my-btn" })) { "Submit" }

    assert_selector "button#my-btn[type='submit'].extra-class.bg-button-primary"
  end

  private

  def variant_fragment(variant)
    {
      default: "bg-button-primary",
      secondary: "bg-button-secondary",
      outline: "border",
      ghost: /ghost-hover/,
      destructive: "bg-button-destructive",
      link: "underline-offset-4"
    }.fetch(variant)
  end
end
