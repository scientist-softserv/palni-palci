# frozen_string_literal: true

class SingleSignonController < DeviseController
  include WorkAuthorization::StoreUrlForScope

  def index
    prepare_for_conditional_work_authorization!
    @identity_providers = IdentityProvider.all
    render && return unless @identity_providers.count.zero?
    redirect_to main_app.new_user_session_path
  end
end
