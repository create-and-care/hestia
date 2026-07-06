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
    assert_includes document.errors[:file], "can't be blank"
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

  private
    def attach_sample_file(document)
      document.file.attach(
        io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")),
        filename: "sample.pdf",
        content_type: "application/pdf"
      )
    end
end
