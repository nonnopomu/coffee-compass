class SearchesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :area, :tag ]

  def area
    @available_prefectures = Cafe.published
                                 .distinct
                                 .order(:prefecture)
                                 .pluck(:prefecture)
  end

  def tag
    @brew_method_tags = Tag.where(category: :brew_method).order(:display_order)
    @feature_tags = Tag.where(category: :cafe_feature).order(:display_order)
  end
end
