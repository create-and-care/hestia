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

  test "create with a blank name does not persist and flashes an error" do
    assert_no_difference -> { DocumentFolder.count } do
      post document_folders_path, params: { document_folder: { name: "" } }
    end
    assert_redirected_to documents_path
    assert_not_nil flash[:alert]
  end

  test "gets the edit form" do
    get edit_document_folder_path(document_folders(:alpha_admin))
    assert_response :success
  end

  test "cannot edit another household's folder" do
    get edit_document_folder_path(document_folders(:beta_folder))
    assert_response :not_found
  end

  test "update renames a folder and sets its color" do
    folder = document_folders(:alpha_admin)
    patch document_folder_path(folder), params: { document_folder: { name: "Papiers", color: "blue" } }
    assert_redirected_to documents_path
    folder.reload
    assert_equal "Papiers", folder.name
    assert_equal "blue", folder.color
  end

  test "update with a blank name re-renders the edit form" do
    folder = document_folders(:alpha_admin)
    patch document_folder_path(folder), params: { document_folder: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal "Administratif", folder.reload.name
  end

  test "cannot update another household's folder" do
    patch document_folder_path(document_folders(:beta_folder)), params: { document_folder: { name: "Hack" } }
    assert_response :not_found
  end
end
