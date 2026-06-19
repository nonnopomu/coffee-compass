require "rails_helper"

RSpec.describe "Public pages", type: :request do
  describe "未ログインユーザーの公開画面アクセス" do
    it "トップページを閲覧できること" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "トップページでエリア・タグ検索のモーダル導線を確認できること" do
      create_cafe(prefecture: "愛知県", status: :published)
      create_tag(name: "ハンドドリップ", category: :brew_method)
      create_tag(name: "落ち着いている", category: :cafe_feature)

      get root_path

      expect(response.body).to include("エリアから探す")
      expect(response.body).to include("タグから探す")
      expect(response.body).to include("エリアを選択")
      expect(response.body).to include("タグを選択")
      expect(response.body).to include("愛知県")
      expect(response.body).to include("ハンドドリップ")
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
