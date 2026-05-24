class Area < ApplicationRecord
  has_many :cafes, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :prefecture, presence: true, length: { maximum: 50 }
  validates :city, presence: true, length: { maximum: 50 }
  validates :name, uniqueness: { scope: [ :prefecture, :city ] }
  validates :region, presence: true, length: { maximum: 50 }
end
