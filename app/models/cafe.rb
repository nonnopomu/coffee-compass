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
end
