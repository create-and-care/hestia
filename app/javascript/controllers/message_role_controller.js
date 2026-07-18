import { Controller } from "@hotwired/stimulus"

// Message.broadcasts_to renders messages/_message.html.erb from a Solid Queue
// job (Turbo::Streams::ActionBroadcastJob) where Current.user is always nil
// (only controller before_actions populate it), so the server can't tell
// "mine vs. theirs" for a live-delivered message — every broadcast message
// renders with the :assistant/"theirs" layout, even for its own author. This
// corrects it client-side, where the viewer's own id is known, by comparing
// each row's data-author-id to the current user's id and flipping the
// row/bubble classes Ui::MessageComponent would have used for role: :user.
export default class extends Controller {
  static targets = [ "row" ]
  static values = { currentUserId: Number }

  rowTargetConnected(row) {
    if (Number(row.dataset.authorId) !== this.currentUserIdValue) return

    const flexRow = row.querySelector(":scope > div")
    const alignDiv = flexRow?.children[1]
    const bubble = alignDiv?.querySelector(":scope > div")
    if (!flexRow || !alignDiv || !bubble) return

    flexRow.classList.add("flex-row-reverse")
    alignDiv.classList.remove("items-start")
    alignDiv.classList.add("items-end")
    bubble.classList.remove("mr-auto", "bg-surface", "text-primary", "border", "border-primary")
    bubble.classList.add("ml-auto", "bg-button-primary", "text-inverse")
  }
}
