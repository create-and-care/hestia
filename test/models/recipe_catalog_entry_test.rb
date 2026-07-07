require "test_helper"

class RecipeCatalogEntryTest < ActiveSupport::TestCase
  test "valid fixture" do
    assert recipe_catalog_entries(:carbonara).valid?
  end

  test "requires a title" do
    entry = RecipeCatalogEntry.new(source_url: "https://example.com/x")
    assert_not entry.valid?
  end

  test "requires a unique source_url" do
    duplicate = RecipeCatalogEntry.new(title: "Autre", source_url: recipe_catalog_entries(:carbonara).source_url)
    assert_not duplicate.valid?
  end

  test "search filters by title" do
    assert_includes RecipeCatalogEntry.search("carbo"), recipe_catalog_entries(:carbonara)
    assert_not_includes RecipeCatalogEntry.search("introuvable"), recipe_catalog_entries(:carbonara)
  end

  test "total_time_minutes sums prep and cook time" do
    assert_equal 25, recipe_catalog_entries(:carbonara).total_time_minutes
  end
end
