class ApplicationComponent < ViewComponent::Base
  # Flattens strings/arrays/hashes (à la clsx) into a single class string.
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
