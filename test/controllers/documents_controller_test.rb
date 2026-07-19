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

  test "create converts an uploaded photo into a readable PDF" do
    file = fixture_file_upload("sample.png", "image/png")
    post documents_path, params: { document: { name: "Photo permis", file: file } }
    document = Document.find_by!(name: "Photo permis")
    assert_equal "application/pdf", document.file.content_type
    assert document.file.filename.to_s.end_with?(".pdf")
  end

  test "create links a documentable from the same household" do
    file = fixture_file_upload("sample.pdf", "application/pdf")
    vehicle = vehicles(:alpha_car)
    post documents_path, params: { document: { name: "Carte grise", file: file, documentable_key: "Vehicle-#{vehicle.id}" } }
    document = Document.find_by!(name: "Carte grise")
    assert_equal vehicle, document.documentable
  end

  test "ignores a documentable from another household" do
    file = fixture_file_upload("sample.pdf", "application/pdf")
    post documents_path, params: { document: { name: "Doc", file: file, documentable_key: "Vehicle-#{vehicles(:beta_car).id}" } }
    assert_nil Document.find_by!(name: "Doc").documentable
  end

  test "search form preserves the active folder filter" do
    folder = document_folders(:alpha_admin)
    get documents_path(folder_id: folder.id)
    assert_response :success
    assert_select "input[name=folder_id][value='#{folder.id}']", 1
  end

  test "folder badges preserve the active search term" do
    folder = document_folders(:alpha_admin)
    get documents_path(q: "Facture")
    assert_response :success
    assert_select "a[href='#{documents_path(folder_id: folder.id, q: "Facture")}']"
  end

  test "gets the edit form" do
    get edit_document_path(documents(:alpha_doc))
    assert_response :success
  end

  test "cannot edit another household's document" do
    get edit_document_path(documents(:beta_doc))
    assert_response :not_found
  end

  test "edit preselects the linked documentable" do
    document = documents(:alpha_doc)
    document.update_columns(documentable_type: "Vehicle", documentable_id: vehicles(:alpha_car).id)

    get edit_document_path(document)
    assert_response :success
    assert_select "option[value='Vehicle-#{vehicles(:alpha_car).id}'][selected]"
  end

  test "update renames a document and moves it to another folder" do
    document = documents(:alpha_doc)
    document.file.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")), filename: "sample.pdf", content_type: "application/pdf")
    folder = households(:alpha).document_folders.create!(name: "Autre dossier")
    patch document_path(document), params: { document: { name: "Nouveau nom", document_folder_id: folder.id } }
    assert_redirected_to documents_path
    document.reload
    assert_equal "Nouveau nom", document.name
    assert_equal folder, document.document_folder
  end

  test "update with a blank name re-renders the edit form" do
    document = documents(:alpha_doc)
    patch document_path(document), params: { document: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal "Facture EDF", document.reload.name
  end

  test "cannot update another household's document" do
    patch document_path(documents(:beta_doc)), params: { document: { name: "Hack" } }
    assert_response :not_found
  end

  test "preview embeds a pdf" do
    document = documents(:alpha_doc)
    document.file.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")), filename: "sample.pdf", content_type: "application/pdf")
    get preview_document_path(document)
    assert_response :success
    assert_includes @response.body, "<iframe"
  end

  test "preview renders an image inline" do
    document = documents(:alpha_doc)
    document.file.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png")
    get preview_document_path(document)
    assert_response :success
    assert_includes @response.body, "<img"
  end

  test "cannot preview another household's document" do
    get preview_document_path(documents(:beta_doc))
    assert_response :not_found
  end
end
