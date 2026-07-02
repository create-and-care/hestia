require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get documents_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's documents only" do
    get documents_path
    assert_response :success
    assert_includes @response.body, "Facture EDF"
    assert_not_includes @response.body, "Document Beta"
  end

  test "create with a file" do
    file = fixture_file_upload("sample.pdf", "application/pdf")
    assert_difference -> { households(:alpha).documents.count }, 1 do
      post documents_path, params: { document: { name: "Contrat", file: file } }
    end
    assert_redirected_to documents_path
    assert Document.find_by(name: "Contrat").file.attached?
  end

  test "create without a file is rejected" do
    assert_no_difference -> { Document.count } do
      post documents_path, params: { document: { name: "Sans fichier" } }
    end
  end

  test "ignores a folder from another household" do
    file = fixture_file_upload("sample.pdf", "application/pdf")
    post documents_path, params: { document: { name: "Doc", file: file, document_folder_id: document_folders(:beta_folder).id } }
    assert_nil Document.find_by(name: "Doc").document_folder_id
  end

  test "create a folder" do
    assert_difference -> { households(:alpha).document_folders.count }, 1 do
      post document_folders_path, params: { document_folder: { name: "Voiture" } }
    end
    assert_redirected_to documents_path
  end

  test "destroy" do
    document = documents(:alpha_doc)
    delete document_path(document)
    assert_redirected_to documents_path
    assert_not Document.exists?(document.id)
  end

  test "cannot access another household's document" do
    get document_path(documents(:beta_doc))
    assert_response :not_found
  end
end
