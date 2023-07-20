class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  skip_before_action :verify_authenticity_token

  def saml
    byebug
    # Here you will need to implement your logic for processing the callback
    # for example, finding or creating a user
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user
      set_flash_message(:notice, :success, kind: params[:provider]) if is_navigational_format?
    else
      session['devise.user_attributes'] = @user.attributes
      redirect_to new_user_registration_url
    end
  end



  # def failure
  #   #redirect_to root_path
  # end
end