class CafesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @cafes = Cafe.published
                 .with_attached_image
                 .includes(:tags, :drink_logs)
    @cafes = @cafes.by_prefectures(params[:prefectures]) if params[:prefectures].present?
    @cafes = @cafes.by_tag_ids(params[:tag_ids])         if params[:tag_ids].present?
    @cafes = @cafes.by_keyword(params[:keyword])          if params[:keyword].present?
    @selected_prefectures = Array(params[:prefectures]).reject(&:blank?)
    @selected_tags = Tag.active_cafe_features.where(id: params[:tag_ids])
    @selected_keyword = params[:keyword].presence
    @available_prefectures = Cafe.available_prefectures
    @feature_tags = Tag.active_cafe_features
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

    @taste_tag_trends = weighted_taste_tag_trends
  end

  def weighted_taste_tag_trends
    taste_tag_scores = Hash.new(0)

    @drink_logs.each do |drink_log|
      drink_log.weighted_taste_tag_scores.each do |tag, score|
        taste_tag_scores[tag] += score
      end
    end

    taste_tag_scores.sort_by do |tag, score|
      [ -score, tag.display_order, tag.name ]
    end
  end
end
