module Ui
  # Toast viewport — mount once (e.g. in the layout). Trigger toasts from anywhere with:
  #   window.dispatchEvent(new CustomEvent("toast:show", { detail: { title, description, variant } }))
  class SonnerComponent < ApplicationComponent
    def call
      tag.div data: { controller: "sonner" }, class: "pointer-events-none fixed bottom-4 right-4 z-[100] flex flex-col gap-2"
    end
  end
end
