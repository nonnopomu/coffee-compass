require "rails_helper"

RSpec.describe "Mypage", type: :request do
  describe "GET /mypage" do
    it "ログインユーザーがマイページを閲覧できること" do
      user = create_user

      sign_in user
      get mypage_path

      expect(response).to have_http_status(:ok)
    end

    it "自分の飲んだログだけ表示されること" do
      user = create_user
      other_user = create_user
      own_log = create_drink_log(user:, menu_name: "自分のログ")
      other_log = create_drink_log(user: other_user, menu_name: "他人のログ")

      sign_in user
      get mypage_path

      expect(response.body).to include(own_log.menu_name)
      expect(response.body).not_to include(other_log.menu_name)
    end

    it "自宅記録がカフェなしで表示されること" do
      user = create_user
      drink_log = build_drink_log(user:, cafe: nil, menu_name: "家で淹れたログ")
      drink_log.brewed_at_home = true
      drink_log.save!

      sign_in user
      get mypage_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(drink_log.menu_name)
      expect(response.body).to include(I18n.t("views.drink_logs.home_brewed_place"))
    end

    it "自分の飲んだログ画像が表示されること" do
      user = create_user
      drink_log = create_drink_log(user:, menu_name: "画像付き自分ログ")
      attach_valid_image(drink_log, :image, filename: "drink_log.png")

      sign_in user
      get mypage_path

      html = Nokogiri::HTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(html.at_css('img[alt="画像付き自分ログ"]')).to be_present
    end

    it "プロフィール編集への導線が表示されること" do
      user = create_user

      sign_in user
      get mypage_path

      expect(response.body).to include(I18n.t("views.common.edit_profile"))
      expect(response.body).not_to include(I18n.t("views.common.view_profile"))
    end

    it "ヘッダーのユーザーメニュー導線が表示されること" do
      user = create_user

      sign_in user
      get mypage_path

      expect(response.body).to include(I18n.t("views.shared.header.open_user_menu"))
      expect(response.body).to include(I18n.t("views.shared.header.mypage"))
      expect(response.body).to include(I18n.t("views.shared.header.account_settings"))
      expect(response.body).to include(I18n.t("views.shared.header.logout"))
      expect(response.body).to include(I18n.t("views.shared.header.logout_confirm"))
      expect(response.body).not_to include(I18n.t("views.shared.header.admin_dashboard"))
    end

    it "管理者のヘッダーには管理者画面への導線が表示されること" do
      admin = create_user(role: :admin)

      sign_in admin
      get mypage_path

      expect(response.body).to include(I18n.t("views.shared.header.admin_dashboard"))
    end

    it "未ログインユーザーがマイページを閲覧できないこと" do
      get mypage_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
