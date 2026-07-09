require "rails_helper"

RSpec.describe "Public pages", type: :request do
  describe "未ログインユーザーの公開画面アクセス" do
    it "トップページを閲覧できること" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "トップページでエリア・タグ検索のモーダル導線を確認できること" do
      create_cafe(prefecture: "愛知県", status: :published)
      create_tag(name: "落ち着いている", category: :cafe_feature)

      get root_path

      expect(response.body).to include("エリアから探す")
      expect(response.body).to include("タグから探す")
      expect(response.body).to include("エリアを選択")
      expect(response.body).to include("タグを選択")
      expect(response.body).to include("愛知県")
      expect(response.body).to include("落ち着いている")
    end

    it "カフェ一覧を閲覧できること" do
      create_cafe(status: :published)

      get cafes_path

      expect(response).to have_http_status(:ok)
    end

    it "カフェ詳細を閲覧できること" do
      cafe = create_cafe(status: :published)

      get cafe_path(cafe)

      expect(response).to have_http_status(:ok)
    end

    it "カフェ詳細でカフェ画像が表示されること" do
      cafe = create_cafe(name: "詳細画像カフェ", status: :published)
      attach_valid_image(cafe, :image, filename: "cafe.png")

      get cafe_path(cafe)

      html = Nokogiri::HTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(html.at_css('img[alt="詳細画像カフェ"]')).to be_present
    end

    it "カフェ詳細のみんなのログで飲んだログ画像が表示されること" do
      cafe = create_cafe(status: :published)
      drink_log = create_drink_log(cafe:, menu_name: "画像付きログ")
      attach_valid_image(drink_log, :image, filename: "drink_log.png")

      get cafe_path(cafe), params: { tab: "logs" }

      html = Nokogiri::HTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(html.at_css('img[alt="画像付きログ"]')).to be_present
    end

    it "カフェ詳細の味わい傾向は小項目タグを大項目タグに寄せて表示すること" do
      cafe = create_cafe(status: :published)
      floral_tag = create_taste_tag(name: "花")
      jasmine_tag = create_taste_tag(name: "ジャスミン", parent: floral_tag)
      chamomile_tag = create_taste_tag(name: "カモミール", parent: floral_tag)
      drink_log = build_drink_log(cafe:, taste_tag: jasmine_tag)
      drink_log.drink_log_taste_tags.build(tag: chamomile_tag, position: 2)
      drink_log.save!

      get cafe_path(cafe)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("花")
    end

    it "カフェ詳細の味わい傾向は選択順の重みづけスコア順に表示すること" do
      cafe = create_cafe(status: :published)
      floral_tag = create_taste_tag(name: "花", display_order: 1)
      berry_tag = create_taste_tag(name: "ベリー", display_order: 2)

      first_drink_log = build_drink_log(cafe:, taste_tag: berry_tag)
      first_drink_log.drink_log_taste_tags.build(tag: floral_tag, position: 2)
      first_drink_log.save!

      second_drink_log = build_drink_log(cafe:, taste_tag: berry_tag)
      second_drink_log.drink_log_taste_tags.build(tag: floral_tag, position: 2)
      second_drink_log.save!

      get cafe_path(cafe)

      html = Nokogiri::HTML(response.body)
      displayed_taste_tag_names = html.css("span")
                                      .map { |span| span.text.strip }
                                      .select { |name| [ berry_tag.name, floral_tag.name ].include?(name) }

      expect(response).to have_http_status(:ok)
      expect(displayed_taste_tag_names.first(2)).to eq([ berry_tag.name, floral_tag.name ])
    end

    it "カフェ詳細の味わい傾向は上位5件まで表示すること" do
      cafe = create_cafe(status: :published)
      taste_tags = Array.new(6) do |index|
        create_taste_tag(name: "味わい#{index + 1}", display_order: index + 1)
      end
      drink_log = build_drink_log(cafe:, taste_tag: taste_tags.first)
      taste_tags.drop(1).each.with_index(2) do |taste_tag, position|
        drink_log.drink_log_taste_tags.build(tag: taste_tag, position:)
      end
      drink_log.save!

      get cafe_path(cafe)

      html = Nokogiri::HTML(response.body)
      trend_list = html.at_css('[data-testid="taste-tag-trend-list"]')
      displayed_taste_tag_names = trend_list.css("span").map { |span| span.text.strip }

      expect(response).to have_http_status(:ok)
      expect(displayed_taste_tag_names).to eq(taste_tags.first(5).map(&:name))
      expect(displayed_taste_tag_names).not_to include(taste_tags.last.name)
    end

    it "飲んだログ詳細を閲覧できること" do
      drink_log = create_drink_log(cafe: create_cafe(status: :published))

      get drink_log_path(drink_log)

      expect(response).to have_http_status(:ok)
    end

    it "利用規約を閲覧できること" do
      get terms_path

      expect(response).to have_http_status(:ok)
    end

    it "プライバシーポリシーを閲覧できること" do
      get privacy_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "ログイン必須画面のアクセス制御" do
    it "飲んだログ作成画面へアクセスできないこと" do
      get new_drink_log_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "飲んだログ編集画面へアクセスできないこと" do
      drink_log = create_drink_log

      get edit_drink_log_path(drink_log)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "マイページへアクセスできないこと" do
      get mypage_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "管理画面へアクセスできないこと" do
      get admin_root_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
