require "test_helper"

# The end-to-end half of I18N-03: a real page, rendered twice, with the date
# coming out in each reader's own order.
#
# The unit guard (test/lib/localized_dates_test.rb) proves `l()` knows both
# orders and that no `strftime` is left in a view. What it cannot prove is that
# the views actually reach for `l()` — a hard-coded "%d/%m/%Y" would satisfy
# neither, but neither would a view that quietly formats its own string. This
# does: 7 August 2026 has to read 07/08/2026 to a French user and 08/07/2026 to
# an English one, off the same template and the same record.
class LocalizedDatesRenderingTest < ActionDispatch::IntegrationTest
  setup do
    @item = households(:alpha).fridge_items.create!(
      name: "Yaourt", location: "refrigerateur", expires_on: Date.new(2026, 8, 7)
    )
  end

  test "a date renders in the reader's own order, from the same template" do
    assert_equal "Jusqu'au 07/08/2026", rendered_line_for("fr")
    assert_equal "Until 08/07/2026", rendered_line_for("en")
  end

  private
    # Scoped to this item's own node: the fixtures carry other dates, and a
    # test that greps the whole page would pass on someone else's.
    def rendered_line_for(locale)
      users(:one).update!(locale: locale)
      sign_in_as(users(:one))

      get fridge_path
      assert_response :success

      css_select("##{ActionView::RecordIdentifier.dom_id(@item)} p").map(&:text)
        .find { |text| text.match?(%r{\d{2}/\d{2}/\d{4}}) }&.strip
    end
end
