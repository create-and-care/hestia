module Pdf
  # Generates the PDF for the calendar's displayed month.
  class CalendarMonthDocument
    def initialize(month, occurrences)
      @month = month
      @occurrences = occurrences # sorted array of [time, event]
    end

    def render
      pdf = Prawn::Document.new(page_size: "A4", margin: 40)
      pdf.text clean(I18n.t("calendar.show.pdf.title", month: month_name, year: @month.year)), size: 22, style: :bold
      pdf.move_down 12

      by_day.each do |date, entries|
        pdf.text "#{day_name(date)} #{date.strftime('%d/%m')}", size: 13, style: :bold
        entries.each do |time, event|
          label = event.all_day ? I18n.t("calendar.show.pdf.all_day") : time.strftime("%H:%M")
          line = "#{label} — #{event.title}"
          line += " (#{event.location})" if event.location.present?
          pdf.text clean(line), indent_paragraphs: 12
        end
        pdf.move_down 8
      end

      pdf.text I18n.t("calendar.show.pdf.no_events") if @occurrences.empty?
      pdf.number_pages "Hestia — page <page>", at: [ 0, 0 ], align: :center, size: 8
      pdf.render
    end

    private
      def by_day
        @occurrences.group_by { |time, _event| time.to_date }
      end

      def day_name(date)
        I18n.t("calendar.show.pdf.day_names")[date.wday]
      end

      def month_name
        I18n.t("calendar.months")[@month.month - 1]
      end

      def clean(text)
        text.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "").encode("UTF-8")
      end
  end
end
