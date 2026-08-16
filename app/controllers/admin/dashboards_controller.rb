class Admin::DashboardsController < Admin::BaseController
  def show
    @users_count = User.count
  end
end
