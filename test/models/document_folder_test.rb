require "test_helper"

class DocumentFolderTest < ActiveSupport::TestCase
  test "requires a name" do
    folder = households(:alpha).document_folders.build
    assert_not folder.valid?
    folder.name = "Administratif"
    assert folder.valid?
  end

  test "ordered scope orders by name" do
    b = households(:alpha).document_folders.create!(name: "Zzz")
    a = households(:alpha).document_folders.create!(name: "Aaa")

    ordered = households(:alpha).document_folders.ordered
    assert_operator ordered.index(a), :<, ordered.index(b)
  end

  test "destroying a folder nullifies its documents rather than destroying them" do
    folder = document_folders(:alpha_admin)
    document = documents(:alpha_doc)
    assert_equal folder, document.document_folder

    assert_no_difference -> { Document.count } do
      folder.destroy
    end
    assert_nil document.reload.document_folder_id
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).document_folders, document_folders(:beta_folder)
  end

  test "color is optional but must be one of the known colors" do
    folder = households(:alpha).document_folders.build(name: "Voiture")
    assert folder.valid?

    folder.color = "blue"
    assert folder.valid?

    folder.color = "chartreuse"
    assert_not folder.valid?
  end
end
