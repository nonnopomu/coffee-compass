require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "バリデーション" do
    it "有効な属性で作成できること" do
      expect(create_taste_tag).to be_valid
    end

    it "名前が必須であること" do
      tag = Tag.new(name: "", category: :taste, display_order: 1)

      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to be_present
    end

    it "名前が50文字以内であること" do
      tag = Tag.new(name: "a" * 51, category: :taste, display_order: 1)

      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to be_present
    end

    it "カテゴリが必須であること" do
      tag = Tag.new(name: "フルーティー", category: nil, display_order: 1)

      expect(tag).not_to be_valid
      expect(tag.errors[:category]).to be_present
    end

    it "表示順が必須であること" do
      tag = Tag.new(name: "フルーティー", category: :taste, display_order: nil)

      expect(tag).not_to be_valid
      expect(tag.errors[:display_order]).to be_present
    end

    it "同じカテゴリ内で同じ名前は登録できないこと" do
      create_taste_tag(name: "フルーティー")
      duplicate_tag = Tag.new(name: "フルーティー", category: :taste, display_order: 2)

      expect(duplicate_tag).not_to be_valid
      expect(duplicate_tag.errors[:name]).to be_present
    end

    it "同じ名前でもカテゴリが異なれば登録できること" do
      create_taste_tag(name: "フルーティー")
      tag = Tag.new(name: "フルーティー", category: :cafe_feature, display_order: 1)

      expect(tag).to be_valid
    end
  end

  describe "カテゴリ" do
    it "焙煎度、味わい、提供スタイル、店舗特徴を扱えること" do
      expect(described_class.categories).to include(
        "roast_level" => 0,
        "taste" => 1,
        "brew_method" => 2,
        "cafe_feature" => 3
      )
    end

    it "初期状態で有効タグになること" do
      tag = Tag.new(name: "フルーティー", category: :taste, display_order: 1)

      expect(tag).to be_is_active
    end
  end

  describe "関連付け" do
    it "カフェに紐づけられること" do
      tag = create_cafe_feature_tag
      cafe = create_cafe
      CafeTag.create!(cafe:, tag:)

      expect(tag.cafes).to include(cafe)
    end

    it "味わいタグとして飲んだログに紐づけられること" do
      tag = create_taste_tag
      drink_log = create_drink_log(taste_tag: tag)

      expect(tag.drink_logs).to include(drink_log)
    end

    it "タグ削除時にカフェタグも削除されること" do
      tag = create_cafe_feature_tag
      CafeTag.create!(cafe: create_cafe, tag:)

      expect { tag.destroy }.to change(CafeTag, :count).by(-1)
    end

    it "タグ削除時に飲んだログの味わいタグ中間レコードも削除されること" do
      tag = create_taste_tag
      create_drink_log(taste_tag: tag)

      expect { tag.destroy }.to change(DrinkLogTasteTag, :count).by(-1)
    end
  end
end
