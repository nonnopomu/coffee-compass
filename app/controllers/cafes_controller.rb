class CafesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @cafes = Cafe.published.includes(:area, :tags, :drink_logs)
  end
end
