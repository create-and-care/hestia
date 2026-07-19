module Ui
  class AlertDialogComponent < ApplicationComponent
    renders_one :trigger

    def initialize(title:, description: nil, confirm_label: I18n.t("ui.alert_dialog.confirm_label"), cancel_label: I18n.t("ui.alert_dialog.cancel_label"))
      @title = title
      @description = description
      @confirm_label = confirm_label
      @cancel_label = cancel_label
    end
  end
end
