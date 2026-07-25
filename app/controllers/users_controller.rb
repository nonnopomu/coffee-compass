class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show ]

  def show
    @user = User.find(params[:id])

    published_drink_logs = @user.drink_logs.published

    @recorded_logs_count = published_drink_logs.count
    @visited_cafes_count = published_drink_logs.distinct.count(:cafe_id)

    @drink_logs = published_drink_logs
                    .with_display_associations
                    .recent_first
                    .page(params[:page])
                    .per(10)
  end
end
