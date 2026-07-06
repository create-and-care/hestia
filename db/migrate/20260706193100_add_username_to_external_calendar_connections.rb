class AddUsernameToExternalCalendarConnections < ActiveRecord::Migration[8.1]
  def change
    # CalDAV servers (Apple/Nextcloud/Fastmail...) authenticate via HTTP Basic
    # Auth with a username + app-specific password, unlike Google/Microsoft's
    # OAuth flow — the password itself is stored (encrypted) in the existing
    # `access_token` column to avoid a redundant dedicated column.
    add_column :external_calendar_connections, :username, :string
  end
end
