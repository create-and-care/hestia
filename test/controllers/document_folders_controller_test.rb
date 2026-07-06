require "test_helper"

class DocumentFoldersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post document_folders_path, params: { document_folder: { name: "Voiture" } }
    assert_redirected_to new_session_path
  end

  test "create adds a folder to the household" do
    assert_difference -> { households(:alpha).document_folders.count }, 1 do
      post document_folders_path, params: { document_folder: { name: "Voiture" } }
    end
    assert_redirected_to documents_path
  end

  test "destroy" do
    folder = document_folders(:alpha_admin)
    delete document_folder_path(folder)
    assert_redirected_to documents_path
    assert_not DocumentFolder.exists?(folder.id)
  end

  test "destroy nullifies its documents rather than destroying them" do
    folder = document_folders(:alpha_admin)
    document = documents(:alpha_doc)
    assert_no_difference -> { Document.count } do
      delete document_folder_path(folder)
    end
    assert_nil document.reload.document_folder_id
  end

  test "cannot destroy another household's folder" do
    delete document_folder_path(document_folders(:beta_folder))
    assert_response :not_found
  end
end
