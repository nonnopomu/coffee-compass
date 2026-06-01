require "rails_helper"

RSpec.describe "Cafe search", type: :request do
  describe "GET /cafes" do
    it "公開中のカフェだけ表示されること" do
      published_cafe = create_cafe(name: "公開カフェ", status: :published)
      draft_cafe = create_cafe(name: "下書きカフェ", status: :draft)
      closed_cafe = create_cafe(name: "閉店カフェ", status: :closed)

      get cafes_path

      expect(response.body).to include(published_cafe.name)
      expect(response.body).not_to include(draft_cafe.name)
      expect(response.body).not_to include(closed_cafe.name)
    end

    it "都道府県で絞り込めること" do
      tokyo_cafe = create_cafe(name: "東京カフェ", prefecture: "東京都", status: :published)
      hokkaido_cafe = create_cafe(name: "北海道カフェ", prefecture: "北海道", status: :published)

      get cafes_path, params: { prefectures: [ "東京都" ] }

      expect(response.body).to include(tokyo_cafe.name)
      expect(response.body).not_to include(hokkaido_cafe.name)
    end

    it "タグで絞り込めること" do
      quiet_tag = create_cafe_feature_tag(name: "静かな空間")
      wifi_tag = create_cafe_feature_tag(name: "Wi-Fiあり")
      quiet_cafe = create_cafe(name: "静かなカフェ", status: :published)
      wifi_cafe = create_cafe(name: "作業カフェ", status: :published)
      CafeTag.create!(cafe: quiet_cafe, tag: quiet_tag)
      CafeTag.create!(cafe: wifi_cafe, tag: wifi_tag)

      get cafes_path, params: { tag_ids: [ quiet_tag.id ] }

      expect(response.body).to include(quiet_cafe.name)
      expect(response.body).not_to include(wifi_cafe.name)
    end

    it "キーワードで絞り込めること" do
      name_matched = create_cafe(name: "青山ロースター", status: :published)
      address_matched = create_cafe(name: "住所一致カフェ", address: "東京都新宿区1-1-1", status: :published)
      unmatched = create_cafe(name: "別のカフェ", address: "北海道札幌市1-1-1", status: :published)

      get cafes_path, params: { keyword: "青山" }

      expect(response.body).to include(name_matched.name)
      expect(response.body).not_to include(address_matched.name)
      expect(response.body).not_to include(unmatched.name)

      get cafes_path, params: { keyword: "新宿" }

      expect(response.body).to include(address_matched.name)
      expect(response.body).not_to include(unmatched.name)
    end
  end
end
