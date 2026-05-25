class CafesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @cafes = Cafe.published.includes(:area, :tags, :drink_logs)

    if params[:prefectures].present?
      area_ids = Area.where(prefecture: params[:prefectures]).pluck(:id)
      @cafes = @cafes.where(area_id: area_ids)
    end

    if params[:tag_ids].present?
      @cafes = @cafes.joins(:tags).where(tags: { id: params[:tag_ids] }).distinct
    end

    if params[:keyword].present?
      keyword = "%#{params[:keyword]}%"
      @cafes = @cafes.where("name LIKE ? OR address LIKE ? OR description LIKE ?", keyword, keyword, keyword)
    end
  end

  def show
    @cafe = Cafe.includes(:area, :tags, :drink_logs).find(params[:id])
  end
end
