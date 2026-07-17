require "rails_helper"

RSpec.describe Cafe, type: :model do
  describe "バリデーション" do
    it "有効な属性で作成できること" do
      expect(build_cafe).to be_valid
    end

    it "都道府県が必須であること" do
      cafe = build_cafe(prefecture: "")

      expect(cafe).not_to be_valid
      expect(cafe.errors[:prefecture]).to be_present
    end

    it "店舗名が必須であること" do
      cafe = build_cafe(name: "")

      expect(cafe).not_to be_valid
      expect(cafe.errors[:name]).to be_present
    end

    it "住所が必須であること" do
      cafe = build_cafe(address: "")

      expect(cafe).not_to be_valid
      expect(cafe.errors[:address]).to be_present
    end

    it "Google Maps URLが必須であること" do
      cafe = build_cafe(google_maps_url: "")

      expect(cafe).not_to be_valid
      expect(cafe.errors[:google_maps_url]).to be_present
    end

    it "都道府県が50文字以内であること" do
      cafe = build_cafe(prefecture: "a" * 51)

      expect(cafe).not_to be_valid
      expect(cafe.errors[:prefecture]).to be_present
    end

    it "店舗名が100文字以内であること" do
      cafe = build_cafe(name: "a" * 101)

      expect(cafe).not_to be_valid
      expect(cafe.errors[:name]).to be_present
    end

    it "住所が100文字以内であること" do
      cafe = build_cafe(address: "a" * 101)

      expect(cafe).not_to be_valid
      expect(cafe.errors[:address]).to be_present
    end

    it "Google Maps URLが1000文字以内であること" do
      cafe = build_cafe(google_maps_url: "https://example.com/" + ("a" * 1001))

      expect(cafe).not_to be_valid
      expect(cafe.errors[:google_maps_url]).to be_present
    end

    it "同じ店舗名と住所の組み合わせは登録できないこと" do
      existing_cafe = create_cafe(name: "重複カフェ", address: "東京都渋谷区1-1-1")
      duplicate_cafe = build_cafe(name: existing_cafe.name, address: existing_cafe.address)

      expect(duplicate_cafe).not_to be_valid
      expect(duplicate_cafe.errors[:name]).to be_present
    end

    it "同じ店舗名でも住所が異なれば登録できること" do
      create_cafe(name: "同名カフェ", address: "東京都渋谷区1-1-1")
      cafe = build_cafe(name: "同名カフェ", address: "東京都渋谷区2-2-2")

      expect(cafe).to be_valid
    end

    it "カフェ画像はJPEG、PNG、WebP形式を添付できること" do
      {
        "image/jpeg" => "cafe.jpg",
        "image/png" => "cafe.png",
        "image/webp" => "cafe.webp"
      }.each do |content_type, filename|
        cafe = build_cafe

        attach_valid_image(cafe, :image, content_type:, filename:)

        expect(cafe).to be_valid
      end
    end

    it "カフェ画像に許可されていない形式は添付できないこと" do
      cafe = build_cafe

      attach_invalid_type_image(cafe, :image)

      expect(cafe).not_to be_valid
      expect(cafe.errors[:image]).to include(I18n.t("activerecord.errors.messages.invalid_image_type"))
    end

    it "カフェ画像は5MB以下であること" do
      cafe = build_cafe

      attach_oversized_image(cafe, :image)

      expect(cafe).not_to be_valid
      expect(cafe.errors[:image]).to include(I18n.t("activerecord.errors.messages.image_too_large", max_size: "5MB"))
    end
  end

  describe "ステータス" do
    it "初期値がdraftであること" do
      expect(described_class.new).to be_draft
    end

    it "draft、published、closedを扱えること" do
      expect(described_class.statuses).to include("draft" => 0, "published" => 1, "closed" => 2)
    end
  end

  describe "関連付け" do
    it "タグを紐づけられること" do
      cafe = create_cafe
      tag = create_cafe_feature_tag

      cafe.tags << tag

      expect(cafe.tags).to include(tag)
    end

    it "カフェ削除時にカフェタグも削除されること" do
      cafe = create_cafe
      tag = create_cafe_feature_tag
      CafeTag.create!(cafe:, tag:)

      expect { cafe.destroy }.to change(CafeTag, :count).by(-1)
    end

    it "カフェ削除時に紐づく飲んだログも削除されること" do
      cafe = create_cafe
      create_drink_log(cafe:)

      expect { cafe.destroy }.to change(DrinkLog, :count).by(-1)
    end
  end

  describe "検索用scope" do
    it "都道府県で絞り込めること" do
      tokyo_cafe = create_cafe(prefecture: "東京都")
      hokkaido_cafe = create_cafe(prefecture: "北海道")

      result = described_class.by_prefectures([ "東京都" ])

      expect(result).to include(tokyo_cafe)
      expect(result).not_to include(hokkaido_cafe)
    end

    it "タグIDで絞り込めること" do
      quiet_tag = create_cafe_feature_tag(name: "静か")
      wifi_tag = create_cafe_feature_tag(name: "Wi-Fiあり")
      quiet_cafe = create_cafe
      wifi_cafe = create_cafe
      CafeTag.create!(cafe: quiet_cafe, tag: quiet_tag)
      CafeTag.create!(cafe: wifi_cafe, tag: wifi_tag)

      result = described_class.by_tag_ids([ quiet_tag.id ])

      expect(result).to include(quiet_cafe)
      expect(result).not_to include(wifi_cafe)
    end

    it "カフェ名だけを検索できること" do
      name_matched = create_cafe(name: "青山コーヒー")
      address_matched = create_cafe(name: "住所一致カフェ", address: "東京都青山区テスト2-2-2")
      description_matched = create_cafe(name: "紹介文一致カフェ", description: "青山で浅煎りが人気のお店")
      unmatched = create_cafe(name: "別のカフェ", address: "北海道札幌市1-1-1", description: "深煎り中心")

      result = described_class.by_keyword("青山")

      expect(result).to include(name_matched)
      expect(result).not_to include(address_matched)
      expect(result).not_to include(description_matched)
      expect(result).not_to include(unmatched)
    end
  end
end
