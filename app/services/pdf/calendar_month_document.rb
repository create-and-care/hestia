module Pdf
  # Génère le PDF du mois affiché du calendrier (CDC §9.2).
  class CalendarMonthDocument
    DAY_NAMES = %w[Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi].freeze
    MONTH_NAMES = %w[Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre].freeze

    def initialize(month, occurrences)
      @month = month
      @occurrences = occurrences # tableau trié de [heure, événement]
    end

    def render
      pdf = Prawn::Document.new(page_size: "A4", margin: 40)
      pdf.text clean("Calendrier — #{MONTH_NAMES.fetch(@month.month - 1)} #{@month.year}"), size: 22, style: :bold
      pdf.move_down 12

      by_day.each do |date, entries|
        pdf.text "#{DAY_NAMES.fetch(date.wday)} #{date.strftime('%d/%m')}", size: 13, style: :bold
        entries.each do |time, event|
          label = event.all_day ? "Journée" : time.strftime("%H:%M")
          line = "#{label} — #{event.title}"
          line += " (#{event.location})" if event.location.present?
          pdf.text clean(line), indent_paragraphs: 12
        end
        pdf.move_down 8
      end

      pdf.text "Aucun événement ce mois-ci." if @occurrences.empty?
      pdf.number_pages "Hestia — page <page>", at: [ 0, 0 ], align: :center, size: 8
      pdf.render
    end

    private
      def by_day
        @occurrences.group_by { |time, _event| time.to_date }
      end

      def clean(text)
        text.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "").encode("UTF-8")
      end
  end
end
