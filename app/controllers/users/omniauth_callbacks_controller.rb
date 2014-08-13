class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def campus
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    puts request.env['omniauth.auth']

    if @user.persisted?
      sign_in_and_redirect root_url, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Campus") if is_navigational_format?
    else
      session["devise.campus_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
