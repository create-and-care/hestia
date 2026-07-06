# The Solid Queue admin UI is a whole-instance operator tool, not a per-user
# household feature — it must not inherit ApplicationController's session
# authentication/household scoping (the gem's default `base_controller_class`).
# Set directly on the mattr (rather than via `config.mission_control.jobs.*`,
# copied only during the engine's `before_initialize`, which already ran by
# the time regular initializers like this one execute). Standalone HTTP Basic
# Auth only, credentials read from `mission_control.http_basic_auth_user/password`
# (bin/rails credentials:edit — see README); closed by default until set.
MissionControl::Jobs.base_controller_class = "ActionController::Base"
