class Cafe < ApplicationRecord
  enum :status, { draft: 0, published: 1, closed: 2 }

  belongs_to :area
  has_many :cafe_tags, dependent: :destroy
  has_many :tags, through: :cafe_tags
  has_many :drink_logs, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 100 }
  validates :google_maps_url, presence: true, length: { maximum: 1000 }
  validates :name, uniqueness: { scope: :address }

  scope :by_prefectures, ->(prefectures) {
    area_ids = Area.where(prefecture: prefectures).pluck(:id)
    where(area_id: area_ids)
  }

  scope :by_tag_ids, ->(tag_ids) {
    joins(:tags).where(tags: { id: tag_ids }).distinct
  }

  scope :by_keyword, ->(keyword) {
    k = "%#{keyword}%"
    where("name LIKE ? OR address LIKE ? OR description LIKE ?", k, k, k)
  }
end
