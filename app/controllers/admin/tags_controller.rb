class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: [ :edit, :update ]
  before_action :set_form_options, only: [ :new, :create, :edit, :update ]

  def index
    @tags = Tag.includes(:parent, :children).order(:category, :display_order, :name)
  end

  def new
    default_category = params[:category].presence_in(Tag.categories.keys) || Tag.categories.keys.first
    @tag = Tag.new(
      category: default_category,
      display_order: next_display_order_for(default_category)
    )
  end

  def create
    @tag = Tag.new(tag_params)
    set_default_display_order
    normalize_parent

    if @tag.save
      redirect_to admin_tags_path, notice: t("flash.admin.tags.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @tag.assign_attributes(tag_params)
    normalize_parent

    if @tag.save
      redirect_to admin_tags_path, notice: t("flash.admin.tags.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :category, :parent_id, :display_order, :is_active)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def set_form_options
    @taste_parent_tags = Tag.taste.where(parent_id: nil, is_active: true).order(:display_order, :name)
    @next_display_orders = Tag.categories.keys.index_with { |category| next_display_order_for(category) }
  end

  def next_display_order_for(category)
    return 1 unless Tag.categories.key?(category.to_s)

    Tag.where(category:, is_active: true).maximum(:display_order).to_i + 1
  end

  def set_default_display_order
    return if @tag.display_order.present? || @tag.category.blank?

    @tag.display_order = next_display_order_for(@tag.category)
  end

  def normalize_parent
    @tag.parent_id = nil unless @tag.taste? && @tag.parent_id.present?
  end
end
