class CafesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @cafes = Cafe.published
                 .with_attached_image
                 .includes(:tags, :drink_logs)
    @cafes = @cafes.by_prefectures(params[:prefectures]) if params[:prefectures].present?
    @cafes = @cafes.by_tag_ids(params[:tag_ids])         if params[:tag_ids].present?
    @cafes = @cafes.by_keyword(params[:keyword])          if params[:keyword].present?
  end

  def show
    @cafe = Cafe.with_attached_image.includes(:tags).find(params[:id])
    @drink_logs = @cafe.drink_logs
                       .published
                       .with_attached_image
                       .with_display_associations
                       .recent_first

    set_log_trends
  end

  private

  def set_log_trends
    @roast_level_trends = @drink_logs.group_by(&:roast_level_tag)
                                     .transform_values(&:count)
                                     .sort_by { |tag, count| [ -count, tag.display_order, tag.name ] }

    @taste_tag_trends = @drink_logs.flat_map(&:aggregated_taste_tags)
                                     .tally
                                     .sort_by { |tag, count| [ -count, tag.display_order, tag.name ] }
  end
end
