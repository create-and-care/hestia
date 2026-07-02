module GiftListsHelper
  PERSPECTIVE_LABELS = { "receive" => "Recevoir", "give" => "Offrir" }.freeze
  STATUS_LABELS = { "wanted" => "Souhaité", "bought" => "Offert" }.freeze

  def perspective_label(perspective) = PERSPECTIVE_LABELS.fetch(perspective, perspective)
  def gift_status_label(status) = STATUS_LABELS.fetch(status, status)

  def contact_options
    Current.household.contacts.order(:name).map { |contact| [ contact.name, contact.id ] }
  end
end
