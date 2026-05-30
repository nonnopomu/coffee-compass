class DrinkLogsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]

  def new
    @cafe = Cafe.find(params[:cafe_id]) if params[:cafe_id].present?
    @cafes = Cafe.published.order(:prefecture, :name) unless @cafe
    @drink_log = DrinkLog.new(cafe: @cafe)
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = Tag.where(category: :taste, is_active: true).order(:display_order)
    @brew_method_tags = Tag.where(category: :brew_method, is_active: true).order(:display_order)
  end

  def create
    @drink_log = current_user.drink_logs.build(drink_log_params)

    if @drink_log.save
      redirect_to cafe_path(@drink_log.cafe), notice: "ログを投稿しました"
    else
      set_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @drink_log = DrinkLog.find(params[:id])
  end

  private

  def drink_log_params
    params.require(:drink_log).permit(
      :cafe_id,
      :menu_name,
      :drank_on,
      :roast_level_tag_id,
      :brew_method_tag_id,
      :memo,
      taste_tag_ids: []
    )
  end

  def set_form_options
    @cafe = @drink_log.cafe if @drink_log.cafe.present?
    @cafes = Cafe.published.order(:prefecture, :name) unless @cafe
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = Tag.where(category: :taste, is_active: true).order(:display_order)
    @brew_method_tags = Tag.where(category: :brew_method, is_active: true).order(:display_order)
  end
end
