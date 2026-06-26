module Ui
  class LabelComponent < ApplicationComponent
    def initialize(for_id: nil, html_options: {})
      @for_id = for_id
      @html_options = html_options
    end

    def call
      content_tag :label, for: @for_id, **@html_options,
        class: cn("text-sm font-medium text-primary select-none peer-disabled:opacity-50 peer-disabled:cursor-not-allowed", @html_options[:class]) do
        content
      end
    end
  end
end
