class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def top
    @available_prefectures = Cafe.available_prefectures
    @feature_tags = Tag.active_cafe_features
  end

  def terms
  end

  def privacy
  end
end
