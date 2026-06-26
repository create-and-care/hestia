module Ui
  class KbdComponent < ApplicationComponent
    def call
      content_tag :kbd, class: "inline-flex items-center justify-center rounded-md border border-secondary bg-surface-inset px-1.5 min-w-5 h-5 text-xs font-mono text-secondary" do
        content
      end
    end
  end
end
