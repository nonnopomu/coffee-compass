class DrinkLogTasteTag < ApplicationRecord
  belongs_to :tag
  belongs_to :drink_log

  validates :tag_id, uniqueness: { scope: :drink_log_id }

  validate :tag_must_be_taste

  private

  def tag_must_be_taste
    return unless tag.present?
    errors.add(:tag, "は味わいタグを選択してください") unless tag.taste?
  end
end
