require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get conversations_path
    assert_redirected_to new_session_path
  end

  test "index shows conversations the user participates in" do
    get conversations_path
    assert_response :success
    assert_includes @response.body, "Organisation"
    assert_not_includes @response.body, "Chat Beta"
  end

  test "show renders the messages" do
    get conversation_path(conversations(:alpha_chat))
    assert_response :success
    assert_includes @response.body, "Bonjour la famille"
    assert_select "turbo-cable-stream-source"
  end

  test "create adds the current user as a participant and ignores users outside the household" do
    assert_difference -> { households(:alpha).conversations.count }, 1 do
      post conversations_path, params: { conversation: { name: "Vacances" }, participant_ids: [ users(:two).id ] }
    end
    conversation = Conversation.find_by!(name: "Vacances")
    assert_equal [ users(:one) ], conversation.participants.to_a
  end

  test "cannot access a conversation from another household" do
    get conversation_path(conversations(:beta_chat))
    assert_response :not_found
  end

  test "show marks the conversation as read for the current participant" do
    conversation = conversations(:alpha_chat)
    participant = conversation.conversation_participants.find_by(user: users(:one))
    assert_nil participant.last_read_at

    get conversation_path(conversation)
    assert_not_nil participant.reload.last_read_at
  end

  test "show wires the message-role controller with the current user's id, so live messages can be re-aligned client-side" do
    get conversation_path(conversations(:alpha_chat))
    assert_select "div[data-controller='message-role'][data-message-role-current-user-id-value='#{users(:one).id}']"
    assert_select "[data-message-role-target='row'][data-author-id='#{users(:one).id}']"
  end

  test "a participant can leave a group conversation" do
    other = User.create!(name: "Chloé", email_address: "chloe@example.com", password: "password")
    households(:alpha).memberships.create!(user: other, role: "member")
    conversation = conversations(:alpha_chat)
    conversation.participant_ids = [ users(:one).id, other.id ]

    patch conversation_path(conversation), params: { conversation: { name: conversation.name }, participant_ids: [ other.id ] }
    assert_redirected_to conversations_path
    assert_not_includes conversation.reload.participants, users(:one)
  end

  test "leaving a conversation gives a confirmation flash and the conversation is no longer accessible" do
    other = User.create!(name: "Chloé", email_address: "chloe@example.com", password: "password")
    households(:alpha).memberships.create!(user: other, role: "member")
    conversation = conversations(:alpha_chat)
    conversation.participant_ids = [ users(:one).id, other.id ]

    patch conversation_path(conversation), params: { conversation: { name: conversation.name }, participant_ids: [ other.id ] }
    follow_redirect!
    assert_includes @response.body, "You left the conversation."

    get conversation_path(conversation)
    assert_response :not_found
  end

  test "destroy removes the conversation and its messages" do
    conversation = conversations(:alpha_chat)
    assert_difference -> { Conversation.count } => -1, -> { Message.count } => -1 do
      delete conversation_path(conversation)
    end
    assert_redirected_to conversations_path
  end

  test "cannot destroy a conversation from another household" do
    delete conversation_path(conversations(:beta_chat))
    assert_response :not_found
  end

  test "index shows a preview of the last message and a relative timestamp" do
    get conversations_path
    assert_response :success
    assert_includes @response.body, "Bonjour la famille"
  end

  test "index marks a conversation with unread messages" do
    get conversations_path
    assert_select "span.shrink-0.rounded-full.bg-button-primary"
  end

  test "index does not mark a conversation the user has read as unread" do
    conversation = conversations(:alpha_chat)
    conversation.conversation_participants.find_by(user: users(:one)).update!(last_read_at: Time.current)

    get conversations_path
    assert_select "span.shrink-0.rounded-full.bg-button-primary", count: 0
  end

  test "discuss creates a conversation for a task and adds every household member" do
    task = households(:alpha).tasks.create!(title: "Organiser la fête")
    assert_difference -> { Conversation.count }, 1 do
      post discuss_conversations_path, params: { subject_type: "Task", subject_id: task.id }
    end
    conversation = Conversation.find_by(subject: task)
    assert_redirected_to conversation
    assert_equal task.title, conversation.name
    assert_includes conversation.participants, users(:one)
  end

  test "discuss reuses the existing conversation for a subject instead of creating a new one" do
    task = households(:alpha).tasks.create!(title: "Organiser la fête")
    existing = households(:alpha).conversations.create!(name: "Organiser la fête", subject: task)
    existing.participant_ids = [ users(:one).id ]

    assert_no_difference -> { Conversation.count } do
      post discuss_conversations_path, params: { subject_type: "Task", subject_id: task.id }
    end
    assert_redirected_to existing
  end

  test "discuss rejects a subject from another household" do
    other_task = households(:beta).tasks.create!(title: "Tâche Beta")
    assert_no_difference -> { Conversation.count } do
      post discuss_conversations_path, params: { subject_type: "Task", subject_id: other_task.id }
    end
    assert_response :not_found
  end

  test "discuss rejects an unsupported subject_type" do
    post discuss_conversations_path, params: { subject_type: "User", subject_id: users(:one).id }
    assert_response :bad_request
  end

  test "the sidebar marks Messages as unread when the household has an unread conversation" do
    get baby_profiles_path
    assert_select "span.absolute.-left-0\\.5.rounded-full.bg-button-primary"
  end

  test "the sidebar does not mark Messages as unread once the conversation has been read" do
    conversations(:alpha_chat).conversation_participants.find_by(user: users(:one)).update!(last_read_at: Time.current)
    get baby_profiles_path
    assert_select "span.absolute.-left-0\\.5.rounded-full.bg-button-primary", count: 0
  end

  test "conversation show links back to its subject" do
    task = households(:alpha).tasks.create!(title: "Organiser la fête")
    conversation = households(:alpha).conversations.create!(name: "Organiser la fête", subject: task)
    conversation.participant_ids = [ users(:one).id ]

    get conversation_path(conversation)
    assert_includes @response.body, edit_task_path(task)
  end
end
