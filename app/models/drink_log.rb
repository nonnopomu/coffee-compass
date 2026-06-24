class DrinkLog < ApplicationRecord
  enum :status, { published: 0, hidden: 1 }

  scope :with_display_associations, -> {
    includes(:user, :cafe, :roast_level_tag, :brew_method_tag, :taste_tags)
  }

  scope :recent_first, -> {
    order(drank_on: :desc, created_at: :desc)
  }

  belongs_to :user
  belongs_to :cafe
  belongs_to :roast_level_tag, class_name: "Tag"
  belongs_to :brew_method_tag, class_name: "Tag"
  has_many :drink_log_taste_tags, dependent: :destroy
  has_many :taste_tags, through: :drink_log_taste_tags, source: :tag
  has_one_attached :image

  validates :menu_name, presence: true, length: { maximum: 100 }
  validates :drank_on, presence: true
  validates :memo, length: { maximum: 200 }

  validate :roast_level_tag_must_be_roast_level
  validate :brew_method_tag_must_be_brew_method
  validate :must_have_at_least_one_taste_tag

  private

  def roast_level_tag_must_be_roast_level
    return unless roast_level_tag.present?

    errors.add(:roast_level_tag, :invalid_roast_level) unless roast_level_tag.roast_level?
  end

  def brew_method_tag_must_be_brew_method
    return unless brew_method_tag.present?

    errors.add(:brew_method_tag, :invalid_brew_method) unless brew_method_tag.brew_method?
  end

  def must_have_at_least_one_taste_tag
    errors.add(:base, :taste_tags_required) if drink_log_taste_tags.empty?
  end
end
