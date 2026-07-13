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

    it "カフェ画像がある場合は一覧に表示されること" do
      cafe = create_cafe(name: "画像付きカフェ", status: :published)
      attach_valid_image(cafe, :image, filename: "cafe.png")

      get cafes_path

      html = Nokogiri::HTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(html.at_css('img[alt="画像付きカフェ"]')).to be_present
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

    it "複数条件で絞り込み、選択中の条件と件数を表示できること" do
      quiet_tag = create_cafe_feature_tag(name: "静かな空間")
      wifi_tag = create_cafe_feature_tag(name: "Wi-Fiあり")
      matched_cafe = create_cafe(
        name: "札幌の静かなカフェ",
        prefecture: "北海道",
        address: "北海道札幌市中央区",
        status: :published
      )
      tag_unmatched_cafe = create_cafe(
        name: "札幌の作業カフェ",
        prefecture: "北海道",
        address: "北海道札幌市北区",
        status: :published
      )
      prefecture_unmatched_cafe = create_cafe(
        name: "東京の静かなカフェ",
        prefecture: "東京都",
        address: "東京都渋谷区",
        status: :published
      )
      CafeTag.create!(cafe: matched_cafe, tag: quiet_tag)
      CafeTag.create!(cafe: tag_unmatched_cafe, tag: wifi_tag)
      CafeTag.create!(cafe: prefecture_unmatched_cafe, tag: quiet_tag)

      get cafes_path, params: {
        prefectures: [ "北海道" ],
        tag_ids: [ quiet_tag.id ],
        keyword: "札幌"
      }

      html = Nokogiri::HTML(response.body)

      expect(response.body).to include(matched_cafe.name)
      expect(response.body).not_to include(tag_unmatched_cafe.name)
      expect(response.body).not_to include(prefecture_unmatched_cafe.name)
      expect(response.body).to include("検索結果 1件")
      expect(response.body).to include("エリア: 北海道")
      expect(response.body).to include("タグ: 静かな空間")
      expect(response.body).to include("キーワード: 札幌")
      expect(html.at_css('a[href="/cafes"]')&.text).to include("条件をクリア")
    end

    it "一覧ページで検索条件を変更するフォームを表示できること" do
      create_cafe(name: "北海道カフェ", prefecture: "北海道", status: :published)
      create_cafe_feature_tag(name: "静かな空間")

      get cafes_path

      html = Nokogiri::HTML(response.body)

      expect(response.body).to include("検索条件")
      expect(response.body).to include("エリア")
      expect(response.body).to include("特徴")
      expect(response.body).to include("選択する")
      expect(response.body).to include("この条件で再検索")
      expect(html.at_css('form[action="/cafes"][method="get"]')).to be_present
      expect(html.at_css('input[name="keyword"]')).to be_present
      expect(html.at_css('input[name="prefectures[]"][value="北海道"]')).to be_present
      expect(html.at_css('input[name="tag_ids[]"]')).to be_present
    end

    it "一覧ページの検索条件フォームに現在の検索条件を初期値として反映すること" do
      quiet_tag = create_cafe_feature_tag(name: "静かな空間")
      cafe = create_cafe(
        name: "札幌の静かなカフェ",
        prefecture: "北海道",
        address: "北海道札幌市中央区",
        status: :published
      )
      CafeTag.create!(cafe: cafe, tag: quiet_tag)

      get cafes_path, params: {
        prefectures: [ "北海道" ],
        tag_ids: [ quiet_tag.id ],
        keyword: "札幌"
      }

      html = Nokogiri::HTML(response.body)

      prefecture_checkbox = html.at_css('input[name="prefectures[]"][value="北海道"]')
      tag_checkbox = html.at_css(%(input[name="tag_ids[]"][value="#{quiet_tag.id}"]))
      keyword_input = html.at_css('input[name="keyword"]')

      expect(prefecture_checkbox["checked"]).to eq("checked")
      expect(tag_checkbox["checked"]).to eq("checked")
      expect(keyword_input["value"]).to eq("札幌")
    end

    it "検索結果が0件のとき条件クリア導線を表示すること" do
      create_cafe(name: "青山ロースター", status: :published)

      get cafes_path, params: { keyword: "存在しないカフェ" }

      html = Nokogiri::HTML(response.body)

      expect(response.body).to include("条件に合うカフェが見つかりませんでした")
      expect(response.body).to include("検索結果 0件")
      expect(response.body).to include("キーワード: 存在しないカフェ")
      expect(html.at_css('a[href="/cafes"]')&.text).to include("条件をクリア")
    end
  end
end
