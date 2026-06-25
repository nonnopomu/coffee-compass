class MypagesController < ApplicationController
  def show
    @drink_logs = current_user.drink_logs
                              .with_attached_image
                              .with_display_associations
                              .recent_first
  end
end
