require "rails_helper"

RSpec.describe CafeTag, type: :model do
  describe "バリデーション" do
    it "カフェとタグがあれば作成できること" do
      cafe_tag = described_class.new(cafe: create_cafe, tag: create_cafe_feature_tag)

      expect(cafe_tag).to be_valid
    end

    it "カフェが必須であること" do
      cafe_tag = described_class.new(cafe: nil, tag: create_cafe_feature_tag)

      expect(cafe_tag).not_to be_valid
      expect(cafe_tag.errors[:cafe]).to be_present
    end

    it "タグが必須であること" do
      cafe_tag = described_class.new(cafe: create_cafe, tag: nil)

      expect(cafe_tag).not_to be_valid
      expect(cafe_tag.errors[:tag]).to be_present
    end

    it "同じカフェとタグの組み合わせは重複登録できないこと" do
      cafe = create_cafe
      tag = create_cafe_feature_tag
      described_class.create!(cafe:, tag:)
      duplicate_cafe_tag = described_class.new(cafe:, tag:)

      expect(duplicate_cafe_tag).not_to be_valid
      expect(duplicate_cafe_tag.errors[:cafe_id]).to be_present
    end
  end

  describe "関連付け" do
    it "カフェからタグを参照できること" do
      cafe = create_cafe
      tag = create_cafe_feature_tag
      described_class.create!(cafe:, tag:)

      expect(cafe.tags).to include(tag)
    end
  end
end
