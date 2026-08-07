require "test_helper"

class RoadmapControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get roadmap_path
    assert_redirected_to new_session_path
  end

  test "renders without an active household" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get roadmap_path
    assert_response :success
    assert_includes @response.body, "Foundation"
    assert_includes @response.body, "Hest.AI"
  end

  # A roadmap is read for where the project is going, so upcoming work comes
  # first and the shipped archive runs newest-first beneath it.
  test "lists upcoming work before shipped work, and the shipped work newest first" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get roadmap_path
    assert_response :success

    body = @response.body
    hestai = body.index(I18n.t("roadmap.milestones.hestai.title"))
    newest = body.index(I18n.t("roadmap.milestones.pwa.title"))
    oldest = body.index(I18n.t("roadmap.milestones.foundation.title"))

    assert hestai < newest, "upcoming work should come before shipped work"
    assert newest < oldest, "shipped work should run newest first"
  end

  test "is reachable from onboarding" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get onboarding_path
    assert_select "a[href=?]", roadmap_path
  end
end
