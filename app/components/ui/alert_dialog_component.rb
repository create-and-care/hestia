module Ui
  class AlertDialogComponent < ApplicationComponent
    renders_one :trigger

    # confirm_url turns the confirm action from a decorative "just close the
    # dialog" button into a real button_to submit — the replacement for
    # data: { turbo_confirm: ... } on destructive/irreversible actions.
    def initialize(title:, description: nil, confirm_label: I18n.t("ui.alert_dialog.confirm_label"), cancel_label: I18n.t("ui.alert_dialog.cancel_label"),
                   confirm_url: nil, confirm_method: :post, confirm_variant: :destructive)
      @title = title
      @description = description
      @confirm_label = confirm_label
      @cancel_label = cancel_label
      @confirm_url = confirm_url
      @confirm_method = confirm_method
      @confirm_variant = confirm_variant
    end
  end
end
