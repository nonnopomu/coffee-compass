class DrinkLogsController < ApplicationController
  def new
    @cafe = Cafe.find(params[:cafe_id]) if params[:cafe_id].present?
    @cafes = Cafe.published.order(:prefecture, :name) unless @cafe
    @drink_log = DrinkLog.new(cafe: @cafe)
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = Tag.where(category: :taste, is_active: true).order(:display_order)
    @brew_method_tags = Tag.where(category: :brew_method, is_active: true).order(:display_order)
  end
end
