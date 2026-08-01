require "test_helper"

class DesignSystemControllerTest < ActionDispatch::IntegrationTest
  test "index lists every registered component" do
    get design_system_path
    assert_response :success

    DesignSystemRegistry.all.each do |entry|
      assert_includes @response.body, entry.name
    end
  end

  test "every registered component page renders" do
    DesignSystemRegistry.all.each do |entry|
      get design_system_component_path(entry.slug)
      assert_response :success, "#{entry.slug} did not render"
      assert_includes @response.body, entry.name
    end
  end

  test "colors, typography and icons pages render" do
    get design_system_colors_path
    assert_response :success

    get design_system_typography_path
    assert_response :success

    get design_system_icons_path
    assert_response :success
  end

  test "illustrations page renders the brief and all 4 slots" do
    get design_system_illustrations_path
    assert_response :success

    assert_includes @response.body, "Bloc de prompt réutilisable"
    assert_includes @response.body, "480 × 360px"
    %w[courses fridge gifts onboarding].each do |slug|
      assert_includes @response.body, slug
    end
  end
end
