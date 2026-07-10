require "test_helper"

class Ui::AttachmentComponentTest < ViewComponent::TestCase
  test "renders the file name" do
    render_inline(Ui::AttachmentComponent.new(name: "recette.pdf"))

    assert_selector "p", text: "recette.pdf"
  end

  test "renders the size when provided" do
    render_inline(Ui::AttachmentComponent.new(name: "recette.pdf", size: "2.4 MB"))

    assert_selector "p", text: "2.4 MB"
  end

  test "omits the size element when size is not provided" do
    render_inline(Ui::AttachmentComponent.new(name: "recette.pdf"))

    assert_selector "p", count: 1
  end

  test "renders an accessible remove button by default" do
    render_inline(Ui::AttachmentComponent.new(name: "recette.pdf"))

    assert_selector "button[aria-label='Retirer la pièce jointe']"
  end

  test "omits the remove button when removable is false" do
    render_inline(Ui::AttachmentComponent.new(name: "recette.pdf", removable: false))

    assert_no_selector "button"
  end
end
