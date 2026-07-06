module Pdf
  # Generates the PDF for a shopping list, grouped by aisle (Spec §9.1).
  class ShoppingListDocument
    def initialize(shopping_list)
      @shopping_list = shopping_list
    end

    def render
      pdf = Prawn::Document.new(page_size: "A4", margin: 40)
      pdf.text clean(@shopping_list.name), size: 22, style: :bold
      pdf.move_down 12

      items_by_rayon.each do |rayon, items|
        pdf.text clean(rayon_label(rayon)), size: 13, style: :bold
        items.each do |item|
          box = item.checked ? "[x]" : "[ ]"
          line = "#{box} #{item.name}"
          line += " — #{format_quantity(item)}" if item.quantity.present?
          pdf.text clean(line), indent_paragraphs: 12
        end
        pdf.move_down 8
      end

      pdf.number_pages "Hestia — page <page>", at: [ 0, 0 ], align: :center, size: 8
      pdf.render
    end

    private
      def items_by_rayon
        @shopping_list.items.group_by(&:rayon)
      end

      def rayon_label(rayon)
        ShoppingListItemsHelper::RAYON_LABELS.fetch(rayon, "Autre")
      end

      def format_quantity(item)
        [ item.quantity.to_s.sub(/\.0+\z/, ""), item.unit ].reject(&:blank?).join(" ")
      end

      # Strips characters not representable by the AFM font (emoji…), while
      # keeping French accented characters.
      def clean(text)
        text.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "").encode("UTF-8")
      end
  end
end
