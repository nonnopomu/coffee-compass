class Admin::CafesController < Admin::BaseController
  before_action :set_cafe, only: [ :edit, :update ]

  def index
    @cafes = Cafe.includes(:tags).order(created_at: :desc)
  end

  def new
    @cafe = Cafe.new(status: :draft)
    set_form_options
  end

  def edit
    set_form_options
  end

  def create
    @cafe = Cafe.new(cafe_params)

    if @cafe.save
      redirect_to admin_cafes_path, notice: t("flash.admin.cafes.create")
    else
      set_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @cafe.update(cafe_params)
      redirect_to admin_cafes_path, notice: t("flash.admin.cafes.update")
    else
      set_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_cafe
    @cafe = Cafe.find(params[:id])
  end

  def set_form_options
    @prefectures = SearchesHelper::PREFECTURES_BY_REGION.values.flatten
    @tags = Tag.where(is_active: true).order(:category, :display_order, :name)
  end

  def cafe_params
    params.require(:cafe).permit(
      :prefecture,
      :name,
      :address,
      :opening_hours,
      :closed_days,
      :google_maps_url,
      :website_url,
      :instagram_url,
      :description,
      :status,
      tag_ids: []
    )
  end
end
