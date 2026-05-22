class CafeTag < ApplicationRecord
  belongs_to :cafe
  belongs_to :tag

  validates :cafe_id, uniqueness: { scope: :tag_id }
end
