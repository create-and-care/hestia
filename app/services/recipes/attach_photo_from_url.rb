require "uri"

module Recipes
  # Downloads an image (schema.org/Recipe `image`, or a catalog entry's
  # cached image_url) and attaches it as a recipe's photo — best-effort:
  # a missing or unreachable image never blocks the import/clone itself.
  class AttachPhotoFromUrl
    def self.call(recipe:, image_url:) = new(recipe: recipe, image_url: image_url).call

    def initialize(recipe:, image_url:)
      @recipe = recipe
      @image_url = image_url.to_s.strip
    end

    def call
      return if @image_url.blank?

      bytes = PageFetcher.call(@image_url)
      return if bytes.blank?

      @recipe.photo.attach(io: StringIO.new(bytes), filename: filename)
    rescue StandardError
      nil
    end

    private
      def filename
        name = File.basename(URI.parse(@image_url).path.presence || "photo.jpg")
        name.presence || "photo.jpg"
      rescue URI::InvalidURIError
        "photo.jpg"
      end
  end
end
