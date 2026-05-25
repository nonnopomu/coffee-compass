class CafesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @cafes = Cafe.published.includes(:area, :tags, :drink_logs)
    @cafes = @cafes.by_prefectures(params[:prefectures]) if params[:prefectures].present?
    @cafes = @cafes.by_tag_ids(params[:tag_ids])         if params[:tag_ids].present?
    @cafes = @cafes.by_keyword(params[:keyword])          if params[:keyword].present?
  end

  def show
    @cafe = Cafe.includes(:area, :tags, :drink_logs).find(params[:id])
  end
end
