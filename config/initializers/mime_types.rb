# Register the PDF MIME type for exports (shopping lists, calendar months).
Mime::Type.register "application/pdf", :pdf unless Mime::Type.lookup_by_extension(:pdf)
