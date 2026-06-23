class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :safe_return_path

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || safe_return_path(root_path)
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  private

  def user_not_authorized
    redirect_back fallback_location: root_path, alert: t("flash.authorization.forbidden")
  end

  def safe_return_path(fallback_path, return_to: params[:return_to])
    url_from(return_to) || fallback_path
  end
end
