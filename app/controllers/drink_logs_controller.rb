class DrinkLogsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_drink_log, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def new
    @cafe = Cafe.find(params[:cafe_id]) if params[:cafe_id].present?
    @cafes = Cafe.published.order(:prefecture, :name) unless @cafe
    @drink_log = DrinkLog.new(cafe: @cafe)
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = Tag.where(category: :taste, is_active: true).order(:display_order)
    @brew_method_tags = Tag.where(category: :brew_method, is_active: true).order(:display_order)
  end

  def create
    @drink_log = current_user.drink_logs.build(drink_log_create_params)

    if @drink_log.save
      redirect_to cafe_path(@drink_log.cafe, tab: "logs"), notice: "ログを投稿しました"
    else
      set_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    set_form_options
  end

  def update
    if @drink_log.update(drink_log_update_params)
      redirect_to drink_log_path(@drink_log), notice: "ログを編集しました"
    else
      set_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_path = safe_return_path || cafe_path(@drink_log.cafe, tab: "logs")
    @drink_log.destroy!
    redirect_to redirect_path, notice: "ログを削除しました"
  end

  private

  def drink_log_create_params
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

  def drink_log_update_params
    params.require(:drink_log).permit(
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

  def set_drink_log
    @drink_log = DrinkLog.find(params[:id])
  end

  def authorize_owner!
    redirect_to drink_log_path(@drink_log), alert: "自分のログのみ編集できます" unless @drink_log.user == current_user
  end

  def safe_return_path
    return_to = params[:return_to].to_s
    return return_to if return_to.start_with?("/") && !return_to.start_with?("//")

    nil
  end
end
