class ApplicationComponent < ViewComponent::Base
  # Extensibility convention — pick one, never a third pattern:
  #   class_name: nil        when callers only ever need extra Tailwind classes
  #                           (Card, Alert, Skeleton, ScrollArea…).
  #   html_options: {}       when callers may also need data-*, aria-*, id, or
  #                           other raw attributes (anything interactive or
  #                           JS-hooked) — merge it with `**html_options.except(:class)`
  #                           and fold `html_options[:class]` through `cn`.

  # Flattens strings/arrays/hashes (clsx-style) into a single class string.
  # Hash entries are included only when their value is truthy:
  #   cn("base", { "is-active" => active? }, ["extra", nil])
  def cn(*tokens)
    tokens.flatten.flat_map { |token|
      case token
      when Hash
        token.select { |_, v| v }.keys
      else
        token
      end
    }.compact_blank.join(" ")
  end
end
