require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /users/:id" do
    it "未ログインユーザーでも公開プロフィールを閲覧できること" do
      user = create_user(name: "公開ユーザー")

      get user_path(user)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("公開ユーザー")
    end

    it "公開プロフィールにメールアドレスが表示されないこと" do
      user = create_user(email: "profile-hidden@example.com")

      get user_path(user)

      expect(response.body).not_to include("profile-hidden@example.com")
    end

    it "公開中の飲んだログだけ表示されること" do
      user = create_user
      published_log = create_drink_log(user:, menu_name: "表示されるログ", status: :published)
      hidden_log = create_drink_log(user:, menu_name: "表示されないログ", status: :hidden)

      get user_path(user)

      expect(response.body).to include(published_log.menu_name)
      expect(response.body).not_to include(hidden_log.menu_name)
    end

    it "プロフィール編集ボタンは本人にだけ表示されること" do
      user = create_user
      other_user = create_user

      sign_in user
      get user_path(user)

      expect(response.body).to include(I18n.t("views.common.edit_profile"))

      get user_path(other_user)

      expect(response.body).not_to include(I18n.t("views.common.edit_profile"))
    end
  end
end
