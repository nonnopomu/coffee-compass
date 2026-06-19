class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def top
    @available_prefectures = Cafe.published
                                 .distinct
                                 .order(:prefecture)
                                 .pluck(:prefecture)
    @brew_method_tags = Tag.where(category: :brew_method, is_active: true).order(:display_order)
    @feature_tags = Tag.where(category: :cafe_feature, is_active: true).order(:display_order)
  end

  def terms
  end

  def privacy
  end
end
