# Lets a user revoke one of their own signed-in devices (Spec §5), listed as
# a "Sessions" tab in household settings (households#show) — not a page of
# its own, mirroring how API tokens and notification preferences already work.
class ActiveSessionsController < ApplicationController
  allow_without_household

  def destroy
    session = Current.user.sessions.find(params[:id])
    is_current = session == Current.session
    session.destroy

    if is_current
      cookies.delete(:session_id)
      redirect_to new_session_path
    else
      redirect_to(Current.household ? household_path(Current.household) : onboarding_path, notice: t(".revoked"))
    end
  end
end
