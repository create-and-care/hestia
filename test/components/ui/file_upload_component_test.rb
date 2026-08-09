require "test_helper"

class Ui::FileUploadComponentTest < ViewComponent::TestCase
  test "renders a file input wired to the stimulus controller" do
    render_inline(Ui::FileUploadComponent.new(name: "recipe[photo]", accept: "image/*"))

    assert_selector "div[data-controller='file-upload']"
    assert_selector "input[type='file'][name='recipe[photo]'][accept='image/*'][data-file-upload-target='input']", visible: :all
  end

  test "shows the placeholder and hides the preview when there is no existing file" do
    render_inline(Ui::FileUploadComponent.new(name: "photo"))

    assert_selector "div[data-file-upload-target='placeholder']:not([hidden])"
    assert_selector "div[data-file-upload-target='preview'][hidden]", visible: :all
    assert_selector "button[data-file-upload-target='removeButton'][hidden]", visible: :all
  end

  test "shows an image preview and hides the placeholder when an existing image is attached" do
    render_inline(Ui::FileUploadComponent.new(name: "photo", existing_url: "/photo.jpg", existing_image: true))

    assert_selector "div[data-file-upload-target='preview']:not([hidden])"
    assert_selector "img[data-file-upload-target='previewImage'][src='/photo.jpg']:not([hidden])"
    assert_selector "div[data-file-upload-target='previewChip'][hidden]", visible: :all
    assert_selector "div[data-file-upload-target='placeholder'][hidden]", visible: :all
    assert_selector "button[data-file-upload-target='removeButton']:not([hidden])"
  end

  test "shows a filename chip instead of an image for a non-image existing file" do
    render_inline(Ui::FileUploadComponent.new(name: "file", accept: "application/pdf,image/*",
      existing_url: "/doc.pdf", existing_filename: "contrat.pdf", existing_image: false))

    assert_selector "div[data-file-upload-target='previewChip']:not([hidden])", text: "contrat.pdf"
    assert_selector "img[data-file-upload-target='previewImage'][hidden]", visible: :all
  end

  test "applies the circle shape to the image preview" do
    render_inline(Ui::FileUploadComponent.new(name: "photo", existing_url: "/avatar.jpg", shape: :circle))

    assert_selector "img[data-file-upload-target='previewImage'].rounded-full"
  end

  test "marks the dropzone as invalid" do
    render_inline(Ui::FileUploadComponent.new(name: "photo", invalid: true))

    assert_selector "input[aria-invalid='true']", visible: :all
    assert_selector "div[data-file-upload-target='dropzone'].border-destructive"
  end

  test "merges html_options and uses the given id" do
    render_inline(Ui::FileUploadComponent.new(name: "photo", html_options: { id: "pet_photo", required: true }))

    assert_selector "input[id='pet_photo'][required]", visible: :all
  end

  # The dropzone's prompt and its remove button were written in French, in
  # English-by-default markup, and read that way in both locales. i18n:check
  # could not see it: there was no key to be missing.
  test "the dropzone prompt and the remove button read in the current locale" do
    render_inline(Ui::FileUploadComponent.new(name: "photo"))

    assert_selector "div[data-file-upload-target='placeholder']", text: "Click to choose or drag and drop a file"
    assert_selector "div[data-file-upload-target='placeholder'] span.text-brand", text: "Click to choose"

    render_inline(Ui::FileUploadComponent.new(name: "photo", existing_url: "/photo.jpg"))

    assert_selector "button[data-file-upload-target='removeButton'][aria-label='Remove file']"
  end

  test "...and in French" do
    I18n.with_locale(:fr) do
      render_inline(Ui::FileUploadComponent.new(name: "photo"))
    end

    assert_selector "div[data-file-upload-target='placeholder']", text: "Cliquez pour choisir ou glissez-déposez un fichier"

    I18n.with_locale(:fr) do
      render_inline(Ui::FileUploadComponent.new(name: "photo", existing_url: "/photo.jpg"))
    end

    assert_selector "button[data-file-upload-target='removeButton'][aria-label='Retirer le fichier']"
  end

  test "compact mode renders a single row-height control instead of the dropzone" do
    render_inline(Ui::FileUploadComponent.new(name: "photo", compact: true))

    assert_selector "div[data-file-upload-target='dropzone'].h-10"
    assert_no_selector "div[data-file-upload-target='dropzone'].py-6"
  end

  test "compact mode still shows an existing filename preview" do
    render_inline(Ui::FileUploadComponent.new(name: "photo", compact: true,
      existing_url: "/doc.pdf", existing_filename: "contrat.pdf", existing_image: false))

    assert_selector "span[data-file-upload-target='previewName']", text: "contrat.pdf"
    assert_selector "span[data-file-upload-target='placeholder'][hidden]", visible: :all
  end
end
