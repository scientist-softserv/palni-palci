##
# OVERRIDE
# This decorator splices into Devise to set the store URL for potential WorkAuthorization.
module DeviseSessionDecorator
  ##
  # OVERRIDE
  #
  # @see OmniAuth::Strategies::OpenIDConnectDecorator#requested_work_url
  # @see # https://github.com/scientist-softserv/palni-palci/issues/633
  def new
    prepare_for_conditional_work_authorization!

    super
  end
end

Devise::SessionsController.prepend(WorkAuthorization::StoreUrlForScope)
Devise::SessionsController.prepend(DeviseSessionDecorator)
