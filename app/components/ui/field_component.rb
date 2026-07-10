module Ui
  class FieldComponent < ApplicationComponent
    renders_one :label
    renders_one :control
    renders_one :description
    renders_one :error

    def initialize(id: nil)
      @id = id
    end

    # Field lays out label/control/description/error but never renders the
    # control itself (it's an arbitrary caller-supplied slot), so it can't set
    # aria-describedby/aria-invalid on it automatically — callers wire the
    # control's `html_options` to these ids themselves.
    def description_id
      "#{@id}-description" if @id
    end

    def error_id
      "#{@id}-error" if @id
    end
  end
end
