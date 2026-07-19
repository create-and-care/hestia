# Standalone page for the same content as household settings' Roadmap tab,
# reachable without an active household (e.g. from onboarding, before a user
# has created or joined one) — see Roadmap for the underlying data.
class RoadmapController < ApplicationController
  allow_without_household

  def show
    @phases = Roadmap.phases
    @improvements = Roadmap.improvements
  end
end
