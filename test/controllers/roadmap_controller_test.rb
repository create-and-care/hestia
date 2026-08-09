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

    assert_select "[role='separator']", text: /#{Regexp.escape(I18n.t("roadmap.show.today"))}/

    newest = Roadmap.milestones.select { |milestone| milestone[:date] }.max_by { |milestone| milestone[:date] }
    assert_includes @response.body, I18n.l(newest[:date], format: :long)
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
