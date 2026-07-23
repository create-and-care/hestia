module Ui
  class FileUploadComponent < ApplicationComponent
    SHAPES = {
      rectangle: "h-20 w-32 rounded-md",
      square: "size-20 rounded-md",
      circle: "size-20 rounded-full"
    }.freeze

    def initialize(name:, accept: nil, existing_url: nil, existing_filename: nil, existing_image: true,
                    shape: :rectangle, invalid: false, compact: false, html_options: {})
      @name = name
      @accept = accept
      @existing_url = existing_url
      @existing_filename = existing_filename
      @existing_image = existing_image
      @shape = shape
      @invalid = invalid
      @compact = compact
      @html_options = html_options
      @uid = SecureRandom.hex(4)
    end

    def input_id
      @html_options[:id] || "file-upload-#{@uid}"
    end

    def existing_preview_shown?
      @existing_url.present? || @existing_filename.present?
    end

    def existing_image_preview?
      @existing_image && @existing_url.present?
    end

    def existing_chip_preview?
      existing_preview_shown? && !existing_image_preview?
    end

    def preview_shape_classes
      SHAPES.fetch(@shape)
    end
  end
end
