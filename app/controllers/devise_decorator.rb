# This decorator splices into Devise to manage the authorization expiration
module DeviseSessionDecorator
  def create
    # We have authenticated the user, but have not yet issued the respond_with (e.g. redirect to the
    # stored location).
    super do
      # Note: Accessing `stored_location_for` clears that location from the session; so we need to
      # grab it and then set it again.
      url = stored_location_for(:user)
      store_location_for(:user, url)

      work_pid = work_pid_from_url(url)
      WorkAuthorization.handle_signin_for!(user: current_user, work_pid: work_pid)
    end
  end

  private

  REGEXP_TO_MATCH_PID = %r{/concern/[^\/]+/(?<work_pid>[^\?]+)(\?.*)?}.freeze
  def work_pid_from_url(url)
    return unless url.present?
    match = REGEXP_TO_MATCH_PID.match(url)
    return unless match
    match[:work_pid]
  end
end

# Don't unleash this into production code; however the functionality is useful for testing.
Devise::SessionsController.prepend(DeviseSessionDecorator) if Rails.env.development?
