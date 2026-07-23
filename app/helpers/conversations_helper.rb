module ConversationsHelper
  def conversation_subject_label(subject)
    subject.try(:title) || subject.try(:name)
  end

  # Conversations the current user can attach a new subject to via the
  # "Discuss this" dialog — only ones with no subject of their own yet, so we
  # never silently reassign an existing subject/conversation pairing.
  def discussable_conversations
    Current.household.conversations
      .joins(:conversation_participants)
      .where(conversation_participants: { user_id: Current.user.id }, subject_id: nil)
      .distinct
      .order(:name)
  end

  def conversation_subject_path(subject)
    case subject
    when Task then edit_task_path(subject)
    when ShoppingList then shopping_list_path(subject)
    when CalendarEvent then edit_calendar_event_path(subject)
    end
  end
end
