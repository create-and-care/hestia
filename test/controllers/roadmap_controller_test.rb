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
  # first and the shipped archive runs newest-first beneath it. Asserted over
  # every milestone rather than a hand-picked three: the ordering is the whole
  # point of the page, and a sample of three passes on a list sorted by accident.
  test "lists every upcoming milestone before every shipped one, newest shipped first" do
    sign_in_as(User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123"))

    get roadmap_path
    assert_response :success

    done, upcoming = positions_of(Roadmap.milestones).partition { |milestone, _| milestone[:status] == :done }

    assert_operator upcoming.map(&:last).max, :<, done.map(&:last).min,
      "every upcoming milestone should be rendered above the shipped archive"

    # Non-increasing rather than a fixed permutation: a dozen milestones shipped
    # on the same day, and their order among themselves is not what's asserted.
    dates = done.sort_by(&:last).map { |milestone, _| milestone[:date] }
    assert_equal dates.sort.reverse, dates, "shipped milestones should read newest-first"
  end

  test "separates the two blocks with a Today divider, and dates the shipped ones" do
    sign_in_as(User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123"))

    get roadmap_path
    assert_response :success

    assert_select "h2", text: /#{Regexp.escape(I18n.t("roadmap.show.today"))}/

    newest = Roadmap.milestones.select { |milestone| milestone[:status] == :done && milestone[:date] }.max_by { |milestone| milestone[:date] }
    assert_includes @response.body, I18n.l(newest[:date], format: :long)
  end

  test "renders V1 and V2 release group labels in order before shipped milestones" do
    sign_in_as(User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123"))

    get roadmap_path
    assert_response :success

    v1_label = I18n.t("roadmap.show.release.v1")
    v2_label = I18n.t("roadmap.show.release.v2")
    v1_position = @response.body.index(v1_label)
    v2_position = @response.body.index(v2_label)

    # Both labels should appear
    assert v1_position, "V1 release label should be rendered"
    assert v2_position, "V2 release label should be rendered"

    # V1 should come before V2
    assert_operator v1_position, :<, v2_position, "V1 should appear before V2"

    # Verify V1 and V2 milestones appear within their correct sections
    v1_milestones = Roadmap.milestones.select { |m| m[:release] == :v1 }
    v2_milestones = Roadmap.milestones.select { |m| m[:release] == :v2 }

    # Extract section boundaries from the rendered HTML
    today_label = I18n.t("roadmap.show.today")
    v1_end = v2_position  # V1 section ends where V2 section begins
    v2_end = @response.body.index(today_label) || @response.body.length  # V2 section ends at Today divider or end of page

    v1_section = @response.body[v1_position...v1_end]
    v2_section = @response.body[v2_position...v2_end]

    v1_milestones.each do |milestone|
      escaped_title = ERB::Util.html_escape(milestone[:title])
      assert_includes v1_section, escaped_title, "V1 milestone #{milestone[:slug]} should be rendered in V1 section"
      assert_not_includes v2_section, escaped_title, "V1 milestone #{milestone[:slug]} should not appear in V2 section"
    end

    v2_milestones.each do |milestone|
      escaped_title = ERB::Util.html_escape(milestone[:title])
      assert_includes v2_section, escaped_title, "V2 milestone #{milestone[:slug]} should be rendered in V2 section"
      assert_not_includes v1_section, escaped_title, "V2 milestone #{milestone[:slug]} should not appear in V1 section"
    end
  end

  # The same partial is the "Roadmap" tab of household settings, which is where
  # a member with a household actually reads it.
  test "the household settings Roadmap tab renders the same ordering" do
    sign_in_as(users(:one))

    get household_path(households(:alpha), tab: "roadmap")
    assert_response :success

    done, upcoming = positions_of(Roadmap.milestones).partition { |milestone, _| milestone[:status] == :done }
    assert_operator upcoming.map(&:last).max, :<, done.map(&:last).min
  end

  test "is reachable from onboarding" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get onboarding_path
    assert_select "a[href=?]", roadmap_path
  end

  private
    # Each milestone paired with where its title appears in the response, so an
    # ordering can be asserted as a whole instead of title by title.
    def positions_of(milestones)
      milestones.map do |milestone|
        position = @response.body.index(ERB::Util.html_escape(milestone[:title]))
        assert position, "#{milestone[:slug]} was not rendered"
        [ milestone, position ]
      end
    end
end
