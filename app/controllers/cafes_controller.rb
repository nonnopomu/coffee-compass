class CafesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @cafes = Cafe.published.includes(:tags, :drink_logs)
    @cafes = @cafes.by_prefectures(params[:prefectures]) if params[:prefectures].present?
    @cafes = @cafes.by_tag_ids(params[:tag_ids])         if params[:tag_ids].present?
    @cafes = @cafes.by_keyword(params[:keyword])          if params[:keyword].present?
  end

  def show
    @cafe = Cafe.includes(:tags).find(params[:id])
    @drink_logs = @cafe.drink_logs
                       .published
                       .includes(:user, :roast_level_tag, :brew_method_tag, :taste_tags)
                       .order(created_at: :desc)

    set_log_trends
  end

  private

  def set_log_trends
    @roast_level_trends = @drink_logs.group_by(&:roast_level_tag)
                                     .transform_values(&:count)
                                     .sort_by { |tag, count| [ -count, tag.display_order, tag.name ] }

    @brew_method_trends = @drink_logs.group_by(&:brew_method_tag)
                                     .transform_values(&:count)
                                     .sort_by { |tag, count| [ -count, tag.display_order, tag.name ] }

    @taste_tag_trends = @drink_logs.flat_map(&:taste_tags)
                                     .tally
                                     .sort_by { |tag, count| [ -count, tag.display_order, tag.name ] }
  end
end
