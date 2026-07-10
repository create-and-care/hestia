require "test_helper"

class Ui::TypographyComponentTest < ViewComponent::TestCase
  test "renders default paragraph variant" do
    render_inline(Ui::TypographyComponent.new) { "Body copy" }

    assert_selector "p.leading-relaxed", text: "Body copy"
  end

  test "renders every variant with the correct tag and a distinguishing class" do
    Ui::TypographyComponent::VARIANTS.each_key do |variant|
      render_inline(Ui::TypographyComponent.new(variant: variant)) { "Sample text" }

      tag = Ui::TypographyComponent::TAGS.fetch(variant)
      assert_selector "#{tag}", text: "Sample text"
      assert_selector tag.to_s, class: fragment_for(variant)
    end
  end

  test "merges custom html_options including class and id" do
    render_inline(Ui::TypographyComponent.new(variant: :h1, html_options: { id: "my-heading", class: "extra-class" })) { "Title" }

    assert_selector "h1#my-heading.extra-class.text-4xl", text: "Title"
  end

  private

  def fragment_for(variant)
    {
      h1: "text-4xl",
      h2: "text-3xl",
      h3: "text-2xl",
      h4: "text-xl",
      p: "leading-relaxed",
      lead: [ "text-lg", "text-secondary" ],
      large: [ "text-lg", "font-semibold" ],
      small: "leading-none",
      muted: [ "text-sm", "text-secondary" ],
      blockquote: "border-l-2",
      inline_code: "font-mono",
      list: "list-disc"
    }.fetch(variant)
  end
end
