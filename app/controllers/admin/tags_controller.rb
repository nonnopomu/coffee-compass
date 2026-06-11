class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: [ :edit, :update ]

  def index
    @tags = Tag.order(:category, :display_order, :name)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      redirect_to admin_tags_path, notice: t("flash.admin.tags.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_path, notice: t("flash.admin.tags.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :category, :display_order, :is_active)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
