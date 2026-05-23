class CafesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @cafes = Cafe.published.includes(:area, :tags, :drink_logs)
  end

  def show
    @cafe = Cafe.includes(:area, :tags, :drink_logs).find(params[:id])
  end
end
