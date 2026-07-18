require "test_helper"

module Recipes
  class AttachPhotoFromUrlTest < ActiveSupport::TestCase
    test "downloads and attaches the image" do
      stub_request(:get, "https://example.com/tarte.jpg").to_return(status: 200, body: File.binread(Rails.root.join("test/fixtures/files/sample.png")))
      recipe = recipes(:alpha_pancakes)

      Recipes::AttachPhotoFromUrl.call(recipe: recipe, image_url: "https://example.com/tarte.jpg")

      assert recipe.photo.attached?
    end

    test "does nothing when the image_url is blank" do
      recipe = recipes(:alpha_pancakes)
      Recipes::AttachPhotoFromUrl.call(recipe: recipe, image_url: nil)
      assert_not recipe.photo.attached?
    end

    test "does not raise when the download fails" do
      stub_request(:get, "https://example.com/missing.jpg").to_return(status: 404)
      recipe = recipes(:alpha_pancakes)

      assert_nothing_raised do
        Recipes::AttachPhotoFromUrl.call(recipe: recipe, image_url: "https://example.com/missing.jpg")
      end
      assert_not recipe.photo.attached?
    end
  end
end
