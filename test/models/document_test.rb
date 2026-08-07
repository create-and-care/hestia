require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "requires a name" do
    document = households(:alpha).documents.build
    attach_sample_file(document)
    assert_not document.valid?

    document.name = "Contrat"
    assert document.valid?
  end

  test "requires an attached file" do
    document = households(:alpha).documents.build(name: "Contrat")
    assert_not document.valid?
    assert_includes document.errors[:file], error_message(:blank)
  end

  test "document_folder is optional" do
    document = households(:alpha).documents.build(name: "Contrat")
    attach_sample_file(document)
    assert document.valid?
    assert_nil document.document_folder
  end

  test "ordered scope orders by creation date, most recent first" do
    earlier = households(:alpha).documents.new(name: "Ancien")
    attach_sample_file(earlier)
    earlier.save!

    later = households(:alpha).documents.new(name: "Récent")
    attach_sample_file(later)
    later.save!

    earlier.update_column(:created_at, 1.day.ago)

    assert_equal [ later, earlier ], households(:alpha).documents.where(id: [ earlier.id, later.id ]).ordered.to_a
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).documents, documents(:beta_doc)
  end

  test "documentable is optional" do
    document = households(:alpha).documents.build(name: "Contrat")
    attach_sample_file(document)
    assert document.valid?
    assert_nil document.documentable
  end

  test "accepts a documentable from the same household" do
    document = households(:alpha).documents.build(name: "Carte grise", documentable: vehicles(:alpha_car))
    attach_sample_file(document)
    assert document.valid?
  end

  test "rejects a documentable from another household" do
    document = households(:alpha).documents.build(name: "Carte grise", documentable: vehicles(:beta_car))
    attach_sample_file(document)
    assert_not document.valid?
    assert_includes document.errors[:documentable], error_message(:invalid)
  end

  test "destroying the linked vehicle nullifies the document rather than destroying it" do
    document = households(:alpha).documents.build(name: "Carte grise", documentable: vehicles(:alpha_car))
    attach_sample_file(document)
    document.save!

    assert_no_difference -> { Document.count } do
      vehicles(:alpha_car).destroy
    end
    assert_nil document.reload.documentable
  end

  private
    def attach_sample_file(document)
      document.file.attach(
        io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")),
        filename: "sample.pdf",
        content_type: "application/pdf"
      )
    end
end
