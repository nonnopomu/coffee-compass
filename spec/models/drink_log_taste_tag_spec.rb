require "rails_helper"

RSpec.describe DrinkLogTasteTag, type: :model do
  describe "バリデーション" do
    it "飲んだログと味わいタグがあれば作成できること" do
      drink_log_taste_tag = described_class.new(drink_log: create_drink_log, tag: create_taste_tag, position: 2)

      expect(drink_log_taste_tag).to be_valid
    end

    it "飲んだログが必須であること" do
      drink_log_taste_tag = described_class.new(drink_log: nil, tag: create_taste_tag, position: 1)

      expect(drink_log_taste_tag).not_to be_valid
      expect(drink_log_taste_tag.errors[:drink_log]).to be_present
    end

    it "タグが必須であること" do
      drink_log_taste_tag = described_class.new(drink_log: create_drink_log, tag: nil, position: 2)

      expect(drink_log_taste_tag).not_to be_valid
      expect(drink_log_taste_tag.errors[:tag]).to be_present
    end

    it "同じ飲んだログと味わいタグの組み合わせは重複登録できないこと" do
      drink_log = create_drink_log
      tag = drink_log.taste_tags.first
      duplicate_drink_log_taste_tag = described_class.new(drink_log:, tag:, position: 2)

      expect(duplicate_drink_log_taste_tag).not_to be_valid
      expect(duplicate_drink_log_taste_tag.errors[:tag_id]).to be_present
    end

    it "味わいカテゴリ以外のタグは選べないこと" do
      drink_log_taste_tag = described_class.new(drink_log: create_drink_log, tag: create_roast_level_tag, position: 2)

      expect(drink_log_taste_tag).not_to be_valid
      expect(drink_log_taste_tag.errors[:tag]).to be_present
    end

    it "positionが必須であること" do
      drink_log_taste_tag = described_class.new(drink_log: create_drink_log, tag: create_taste_tag, position: nil)

      expect(drink_log_taste_tag).not_to be_valid
      expect(drink_log_taste_tag.errors[:position]).to be_present
    end

    it "positionは1以上の整数であること" do
      drink_log = create_drink_log

      zero_position_tag = described_class.new(drink_log:, tag: create_taste_tag, position: 0)
      decimal_position_tag = described_class.new(drink_log:, tag: create_taste_tag, position: 1.5)

      expect(zero_position_tag).not_to be_valid
      expect(zero_position_tag.errors[:position]).to be_present
      expect(decimal_position_tag).not_to be_valid
      expect(decimal_position_tag.errors[:position]).to be_present
    end

    it "同じ飲んだログ内でpositionは重複登録できないこと" do
      drink_log = create_drink_log
      duplicate_position_tag = described_class.new(drink_log:, tag: create_taste_tag, position: 1)

      expect(duplicate_position_tag).not_to be_valid
      expect(duplicate_position_tag.errors[:position]).to be_present
    end

    it "別の飲んだログであれば同じpositionを登録できること" do
      first_drink_log_taste_tag = create_drink_log.drink_log_taste_tags.first
      second_drink_log_taste_tag = create_drink_log.drink_log_taste_tags.first

      expect(first_drink_log_taste_tag.position).to eq(1)
      expect(second_drink_log_taste_tag.position).to eq(1)
      expect(second_drink_log_taste_tag).to be_valid
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
