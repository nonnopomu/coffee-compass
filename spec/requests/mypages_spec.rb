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

    it "プロフィール編集とアカウント設定への導線が表示されること" do
      user = create_user

      sign_in user
      get mypage_path

      expect(response.body).to include(I18n.t("views.common.edit_profile"))
      expect(response.body).to include(I18n.t("views.common.account_settings"))
      expect(response.body).not_to include(I18n.t("views.common.view_profile"))
    end

    it "未ログインユーザーがマイページを閲覧できないこと" do
      get mypage_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
