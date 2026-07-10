module Ui
  # Wraps a live component preview with a "Code" tab showing the exact ERB
  # used to render it, plus a copy button — the Preview/Code pattern from
  # shadcn/ui's docs. `code:` is typically produced by `design_system_source`
  # (DesignSystemHelper), which reads the preview partial's own source so the
  # snippet can never drift from what's actually rendered.
  class CodeBlockComponent < ApplicationComponent
    def initialize(code:)
      @code = code
    end
  end
end
