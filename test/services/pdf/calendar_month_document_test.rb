require "test_helper"

module Pdf
  class CalendarMonthDocumentTest < ActiveSupport::TestCase
    test "renders a PDF listing the given occurrences" do
      month = Date.current.beginning_of_month
      event = calendar_events(:alpha_meeting)
      occurrences = [ [ event.starts_at, event ] ]

      pdf = Pdf::CalendarMonthDocument.new(month, occurrences).render

      assert pdf.start_with?("%PDF")
    end

    test "renders the no-events message when there are no occurrences" do
      pdf = Pdf::CalendarMonthDocument.new(Date.current.beginning_of_month, []).render

      assert pdf.start_with?("%PDF")
    end
  end
end
