module Ui
  # button_to's own <button> can't be wrapped inside Ui::ButtonComponent (nested <button> would
  # be invalid HTML), so this reconstructs the same variant/size class recipe for button_to call
  # sites — was previously hand-copied verbatim in notes/_note.html.erb and
  # routines/_routine.html.erb.
  class ButtonToComponent < ApplicationComponent
    def initialize(url, method: :post, variant: :outline, size: :sm, html_options: {})
      @url = url
      @method = method
      @variant = variant
      @size = size
      @html_options = html_options
    end

    def call
      classes = cn(
        "inline-flex cursor-pointer items-center rounded-md font-medium transition-colors",
        "disabled:pointer-events-none disabled:opacity-50 focus-visible:ring-focus",
        ButtonComponent::VARIANTS.fetch(@variant),
        ButtonComponent::SIZES.fetch(@size)
      )
      button_to @url, **@html_options.except(:class), method: @method, class: cn(classes, @html_options[:class]) do
        content
      end
    end
  end
end
