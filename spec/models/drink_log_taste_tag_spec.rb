require "rails_helper"

RSpec.describe DrinkLogTasteTag, type: :model do
  describe "バリデーション" do
    it "飲んだログと味わいタグがあれば作成できること" do
      drink_log_taste_tag = described_class.new(drink_log: create_drink_log, tag: create_taste_tag)

      expect(drink_log_taste_tag).to be_valid
    end

    it "飲んだログが必須であること" do
      drink_log_taste_tag = described_class.new(drink_log: nil, tag: create_taste_tag)

      expect(drink_log_taste_tag).not_to be_valid
      expect(drink_log_taste_tag.errors[:drink_log]).to be_present
    end

    it "タグが必須であること" do
      drink_log_taste_tag = described_class.new(drink_log: create_drink_log, tag: nil)

      expect(drink_log_taste_tag).not_to be_valid
      expect(drink_log_taste_tag.errors[:tag]).to be_present
    end

    it "同じ飲んだログと味わいタグの組み合わせは重複登録できないこと" do
      drink_log = create_drink_log
      tag = drink_log.taste_tags.first
      duplicate_drink_log_taste_tag = described_class.new(drink_log:, tag:)

      expect(duplicate_drink_log_taste_tag).not_to be_valid
      expect(duplicate_drink_log_taste_tag.errors[:tag_id]).to be_present
    end

    it "味わいカテゴリ以外のタグは選べないこと" do
      drink_log_taste_tag = described_class.new(drink_log: create_drink_log, tag: create_roast_level_tag)

      expect(drink_log_taste_tag).not_to be_valid
      expect(drink_log_taste_tag.errors[:tag]).to be_present
    end
  end

  describe "関連付け" do
    it "飲んだログから味わいタグを参照できること" do
      taste_tag = create_taste_tag
      drink_log = create_drink_log(taste_tag:)

      expect(drink_log.taste_tags).to include(taste_tag)
    end
  end
end
