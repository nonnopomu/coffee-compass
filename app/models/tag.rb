class Tag < ApplicationRecord
  enum :category, { roast_level: 0, taste: 1, brew_method: 2, cafe_feature: 3 }

  has_many :drink_log_taste_tags, dependent: :destroy
  has_many :cafe_tags, dependent: :destroy
  has_many :drink_logs, through: :drink_log_taste_tags
  has_many :cafes, through: :cafe_tags

  validates :name, presence: true, length: { maximum: 50 }
  validates :category, presence: true
  validates :display_order, presence: true
  validates :name, uniqueness: { scope: :category }
end
