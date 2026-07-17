class Cafe < ApplicationRecord
  include ImageAttachmentValidatable

  enum :status, { draft: 0, published: 1, closed: 2 }

  has_many :cafe_tags, dependent: :destroy
  has_many :tags, through: :cafe_tags
  has_many :drink_logs, dependent: :destroy
  has_one_attached :image

  validates_image_attachment :image

  validates :prefecture, presence: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 100 }
  validates :google_maps_url, presence: true, length: { maximum: 1000 }
  validates :name, uniqueness: { scope: :address }

  scope :by_prefectures, ->(prefectures) {
    where(prefecture: prefectures)
  }

  scope :by_tag_ids, ->(tag_ids) {
    joins(:tags).where(tags: { id: tag_ids }).distinct
  }

  scope :by_keyword, ->(keyword) {
    k = "%#{keyword}%"
    where("cafes.name LIKE ?", k)
  }

  def self.available_prefectures
    published.distinct.order(:prefecture).pluck(:prefecture)
  end

  def self.search_suggestions(keyword, limit: 10)
    keyword_pattern = "%#{sanitize_sql_like(keyword)}%"

    published
      .where("cafes.name LIKE ?", keyword_pattern)
      .limit(limit)
      .map do |cafe|
        {
          type: "cafe",
          label: cafe.name,
          keyword: cafe.name
        }
      end
  end
end
