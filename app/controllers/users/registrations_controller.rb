module Users
  class RegistrationsController < Devise::RegistrationsController
    def destroy
      unless params[:confirm_account_deletion] == "1"
        redirect_to edit_user_registration_path, alert: t("flash.registrations.delete_confirmation_required")
        return
      end

      super
    end
  end
end
