class DrinkLog < ApplicationRecord
  include ImageAttachmentValidatable

  enum :status, { published: 0, hidden: 1 }

  scope :with_display_associations, -> {
    includes(:user, :cafe, :roast_level_tag, taste_tags: :parent)
  }

  scope :recent_first, -> {
    order(drank_on: :desc, created_at: :desc)
  }

  belongs_to :user
  belongs_to :cafe
  belongs_to :roast_level_tag, class_name: "Tag"
  has_many :drink_log_taste_tags, dependent: :destroy
  has_many :taste_tags, through: :drink_log_taste_tags, source: :tag
  has_one_attached :image

  validates_image_attachment :image

  validates :menu_name, presence: true, length: { maximum: 100 }
  validates :drank_on, presence: true
  validates :memo, length: { maximum: 200 }

  validate :roast_level_tag_must_be_roast_level
  validate :must_have_at_least_one_taste_tag

  def aggregated_taste_tags
    taste_tags.map(&:aggregation_target).uniq(&:id)
  end

  private

  def roast_level_tag_must_be_roast_level
    return unless roast_level_tag.present?

    errors.add(:roast_level_tag, :invalid_roast_level) unless roast_level_tag.roast_level?
  end

  def must_have_at_least_one_taste_tag
    errors.add(:base, :taste_tags_required) if drink_log_taste_tags.empty?
  end
end
