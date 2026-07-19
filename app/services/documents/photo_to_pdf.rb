module Documents
  # "Photo capturée -> PDF lisible" (spec): a document uploaded as an image is
  # transparently wrapped in a single-page PDF at upload time instead of being
  # stored as a raw image, so every document in the library is readable the
  # same way regardless of how it was captured.
  class PhotoToPdf
    def self.call(uploaded_file)
      pdf = Prawn::Document.new(margin: 18)
      pdf.image uploaded_file.to_io, fit: [ pdf.bounds.width, pdf.bounds.height ], position: :center, vposition: :center
      StringIO.new(pdf.render)
    end
  end
end
