class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show ]

  def show
    @user = User.find(params[:id])
    @drink_logs = @user.drink_logs
                       .published
                       .with_display_associations
                       .recent_first
  end
end
