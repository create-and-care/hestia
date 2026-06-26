module Ui
  class AlertDialogComponent < ApplicationComponent
    renders_one :trigger

    def initialize(title:, description: nil, confirm_label: "Continue", cancel_label: "Cancel")
      @title = title
      @description = description
      @confirm_label = confirm_label
      @cancel_label = cancel_label
    end
  end
end
