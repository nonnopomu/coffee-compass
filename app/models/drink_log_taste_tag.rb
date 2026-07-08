class DrinkLogTasteTag < ApplicationRecord
  belongs_to :tag
  belongs_to :drink_log

  validates :tag_id, uniqueness: { scope: :drink_log_id }
  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :drink_log_id }

  validate :tag_must_be_taste

  private

  def tag_must_be_taste
    return unless tag.present?

    errors.add(:tag, :invalid_taste_tag) unless tag.taste?
  end
end
