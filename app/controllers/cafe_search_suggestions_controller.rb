class CafeSearchSuggestionsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    keyword = params[:keyword].to_s.strip

    if keyword.blank?
      render json: { suggestions: [] }
      return
    end

    render json: { suggestions: Cafe.search_suggestions(keyword) }
  end
end