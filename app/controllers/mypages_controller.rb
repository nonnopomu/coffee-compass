class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @drink_logs = current_user.drink_logs
                              .includes(:cafe, :roast_level_tag, :brew_method_tag, :taste_tags)
                              .order(drank_on: :desc, created_at: :desc)
  end
end