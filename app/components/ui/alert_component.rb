module Ui
  class AlertComponent < ApplicationComponent
    renders_one :title
    renders_one :icon

    VARIANTS = {
      default: "border-primary text-primary",
      success: "border-primary text-success",
      warning: "border-primary text-warning",
      destructive: "border-destructive text-destructive"
    }.freeze

    def initialize(variant: :default, class_name: nil)
      @variant = variant
      @class_name = class_name
    end
  end
end
