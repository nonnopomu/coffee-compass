class DrinkLogsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show ]
  before_action :set_drink_log, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def new
    @cafe = Cafe.with_attached_image.find(params[:cafe_id]) if params[:cafe_id].present?
    @cafes = Cafe.published.with_attached_image.order(:prefecture, :name) unless @cafe
    @drink_log = DrinkLog.new(cafe: @cafe)
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = beginner_taste_tags
  end

  def create
    @drink_log = current_user.drink_logs.build(drink_log_create_params)
    assign_taste_tags_with_positions(@drink_log)

    if @drink_log.save
      redirect_to drink_log_create_redirect_path, notice: t("flash.drink_logs.create")
    else
      set_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @safe_back_path = safe_return_path(drink_log_fallback_path)
  end

  def edit
    @safe_back_path = safe_return_path(drink_log_path(@drink_log))
    set_form_options
  end

  def update
    updated = false

    DrinkLog.transaction do
      @drink_log.assign_attributes(drink_log_update_params)
      assign_taste_tags_with_positions(@drink_log)

      updated = @drink_log.save
      raise ActiveRecord::Rollback unless updated
    end

    if updated
      @drink_log.image.purge_later if remove_image_requested? && @drink_log.image.attached?

      redirect_to drink_log_path(@drink_log), notice: t("flash.drink_logs.update")
    else
      set_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_path = safe_return_path(drink_log_fallback_path)
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
      :brewed_at_home
    )
  end

  def drink_log_update_params
    params.require(:drink_log).permit(
      :menu_name,
      :drank_on,
      :roast_level_tag_id,
      :memo,
      :image
    )
  end

  def ordered_taste_tag_ids
    raw_ids = params.dig(:drink_log, :ordered_taste_tag_ids).presence ||
              Array(params.dig(:drink_log, :taste_tag_ids)).join(",")

    raw_ids
      .to_s
      .split(",")
      .filter_map { |id| Integer(id, exception: false) }
      .uniq
  end

  def assign_taste_tags_with_positions(drink_log)
    drink_log.drink_log_taste_tags.destroy_all if drink_log.persisted?
    drink_log.drink_log_taste_tags.clear

    ordered_taste_tag_ids.each.with_index(1) do |tag_id, position|
      drink_log.drink_log_taste_tags.build(tag_id:, position:)
    end
  end

  def remove_image_requested?
    params.dig(:drink_log, :remove_image) == "1" && params.dig(:drink_log, :image).blank?
  end

  def set_form_options
    @cafe = @drink_log.cafe if @drink_log.cafe.present?
    @cafes = Cafe.published.with_attached_image.order(:prefecture, :name) unless @cafe
    @roast_level_tags = Tag.where(category: :roast_level, is_active: true).order(:display_order)
    @taste_tags = beginner_taste_tags
  end

  def beginner_taste_tags
    Tag.taste
       .where(parent_id: nil, is_active: true)
       .includes(:children)
       .order(:beginner_display_order, :display_order)
  end

  def set_drink_log
    @drink_log = DrinkLog.find(params[:id])
  end

  def authorize_owner!
    redirect_to drink_log_path(@drink_log), alert: t("flash.drink_logs.owner_required") unless @drink_log.user == current_user
  end

  def drink_log_create_redirect_path
    return mypage_path if @drink_log.brewed_at_home?

    safe_return_path(cafe_path(@drink_log.cafe, tab: "logs"))
  end

  def drink_log_fallback_path
    return mypage_path if @drink_log.brewed_at_home?

    cafe_path(@drink_log.cafe, tab: "logs")
  end
end
