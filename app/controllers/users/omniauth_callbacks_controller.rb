module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    def google_oauth2
      auth = request.env["omniauth.auth"]
      return_to = request.env.dig("omniauth.params", "return_to")

      @user = User.from_omniauth(auth)

      sign_in @user, event: :authentication
      remember_me(@user)
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      redirect_to stored_location_for(@user) || safe_return_path(root_path, return_to: return_to)

    rescue ActiveRecord::RecordInvalid
      redirect_to new_user_session_path, alert: t("flash.omniauth.failure")
    end
  end
end
