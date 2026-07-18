module NotesHelper
  SWATCH_CLASSES = {
    "default" => "bg-surface-inset",
    "yellow" => "bg-yellow-300",
    "pink" => "bg-pink-300",
    "blue" => "bg-blue-300",
    "green" => "bg-green-300",
    "purple" => "bg-purple-300"
  }.freeze

  CARD_CLASSES = {
    "default" => nil,
    "yellow" => "bg-yellow-50 border-yellow-200 dark:bg-yellow-950/40 dark:border-yellow-900",
    "pink" => "bg-pink-50 border-pink-200 dark:bg-pink-950/40 dark:border-pink-900",
    "blue" => "bg-blue-50 border-blue-200 dark:bg-blue-950/40 dark:border-blue-900",
    "green" => "bg-green-50 border-green-200 dark:bg-green-950/40 dark:border-green-900",
    "purple" => "bg-purple-50 border-purple-200 dark:bg-purple-950/40 dark:border-purple-900"
  }.freeze

  def note_color_swatch_class(color)
    SWATCH_CLASSES.fetch(color, SWATCH_CLASSES["default"])
  end

  def note_card_color_class(color)
    CARD_CLASSES.fetch(color, nil)
  end

  # Lightweight Markdown-subset renderer for note content: bold/italic inline spans, "# "
  # headings and "- "/"* " bullet lists. Deliberately not a full ActionText/Trix editor (would
  # add a new JS dependency and asset-pipeline wiring for a household notes field) — this covers
  # the spec's "gras/italique/titres/listes" ask with a plain-text-compatible format that also
  # renders every note written before this feature shipped.
  def format_note_content(content)
    return "" if content.blank?

    blocks = []
    list_items = []
    flush_list = -> { blocks << content_tag(:ul, safe_join(list_items), class: "list-inside list-disc") if list_items.any? }

    content.to_s.each_line(chomp: true) do |line|
      if line.start_with?("- ", "* ")
        list_items << content_tag(:li, format_note_inline(line[2..]))
        next
      end
      flush_list.call
      list_items = []

      next if line.blank?

      blocks << if line.start_with?("# ")
        content_tag(:h3, format_note_inline(line[2..]), class: "font-semibold")
      else
        content_tag(:p, format_note_inline(line))
      end
    end
    flush_list.call

    safe_join(blocks)
  end

  private
    def format_note_inline(text)
      escaped = CGI.escapeHTML(text.to_s)
      escaped = escaped.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
      escaped.gsub(/\*(.+?)\*/, '<em>\1</em>').html_safe
    end
end
