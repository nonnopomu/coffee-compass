class Tag < ApplicationRecord
  enum :category, { roast_level: 0, taste: 1, cafe_feature: 3 }

  belongs_to :parent, class_name: "Tag", optional: true
  has_many :children, class_name: "Tag", foreign_key: :parent_id, dependent: :nullify, inverse_of: :parent
  has_many :drink_log_taste_tags, dependent: :destroy
  has_many :cafe_tags, dependent: :destroy
  has_many :drink_logs, through: :drink_log_taste_tags
  has_many :cafes, through: :cafe_tags

  validates :name, presence: true, length: { maximum: 50 }
  validates :category, presence: true
  validates :display_order, presence: true
  validates :name, uniqueness: { scope: [ :category, :parent_id ] }
  validates :display_order,
            uniqueness: { scope: :category, conditions: -> { where(is_active: true) } },
            if: :validate_active_display_order_uniqueness?

  scope :active_cafe_features, -> {
    where(category: :cafe_feature, is_active: true).order(:display_order)
  }

  def aggregation_target
    parent || self
  end

  private

  def validate_active_display_order_uniqueness?
    is_active? && (
      new_record? ||
        will_save_change_to_category? ||
        will_save_change_to_display_order? ||
        will_save_change_to_is_active?
    )
  end
end
