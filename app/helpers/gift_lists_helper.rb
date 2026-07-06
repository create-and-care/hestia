module GiftListsHelper
  def perspective_label(perspective) = t("gift_lists.perspectives.#{perspective}", default: perspective.to_s.humanize)
  def gift_status_label(status) = t("gift_lists.statuses.#{status}", default: status.to_s.humanize)

  def contact_options
    Current.household.contacts.order(:name).map { |contact| [ contact.name, contact.id ] }
  end
end
