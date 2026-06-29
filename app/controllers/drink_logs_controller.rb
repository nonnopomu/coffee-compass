class DrinkLogsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show ]
  before_action :set_drink_log, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def new
    @cafe = Cafe.find(params[:cafe_id]) if params[:cafe_id].present?
    @cafes = Cafe.published.order(:prefecture, :name) unless @cafe
    @drink_log = DrinkLog.new(cafe: @cafe)
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = Tag.where(category: :taste, is_active: true).order(:display_order)
  end

  def create
    @drink_log = current_user.drink_logs.build(drink_log_create_params)

    if @drink_log.save
      redirect_to safe_return_path(cafe_path(@drink_log.cafe, tab: "logs")), notice: t("flash.drink_logs.create")
    else
      set_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @safe_back_path = safe_return_path(cafe_path(@drink_log.cafe, tab: "logs"))
  end

  def edit
    @safe_back_path = safe_return_path(drink_log_path(@drink_log))
    set_form_options
  end

  def update
    if @drink_log.update(drink_log_update_params)
      @drink_log.image.purge_later if remove_image_requested? && @drink_log.image.attached?

      redirect_to drink_log_path(@drink_log), notice: t("flash.drink_logs.update")
    else
      set_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_path = safe_return_path(cafe_path(@drink_log.cafe, tab: "logs"))
    @drink_log.destroy!
    redirect_to redirect_path, notice: t("flash.drink_logs.destroy")
  end

  private

  def drink_log_create_params
    params.require(:drink_log).permit(
      :cafe_id,
      :menu_name,
      :drank_on,
      :roast_level_tag_id,
      :memo,
      :image,
      taste_tag_ids: []
    )
  end

  def drink_log_update_params
    params.require(:drink_log).permit(
      :menu_name,
      :drank_on,
      :roast_level_tag_id,
      :memo,
      :image,
      taste_tag_ids: []
    )
  end

  def remove_image_requested?
    params.dig(:drink_log, :remove_image) == "1" && params.dig(:drink_log, :image).blank?
  end

  def set_form_options
    @cafe = @drink_log.cafe if @drink_log.cafe.present?
    @cafes = Cafe.published.order(:prefecture, :name) unless @cafe
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = Tag.where(category: :taste, is_active: true).order(:display_order)
  end

  def set_drink_log
    @drink_log = DrinkLog.find(params[:id])
  end

  def authorize_owner!
    redirect_to drink_log_path(@drink_log), alert: t("flash.drink_logs.owner_required") unless @drink_log.user == current_user
  end
end
