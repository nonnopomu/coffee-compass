require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /admin" do
    it "管理者は管理者トップを閲覧できること" do
      admin = create_user(role: :admin)

      sign_in admin
      get admin_root_path

      expect(response).to have_http_status(:ok)
    end

    it "一般ユーザーは管理者トップを閲覧できないこと" do
      user = create_user

      sign_in user
      get admin_root_path

      expect(response).to redirect_to(root_path)
    end

    it "未ログインユーザーはログイン画面へリダイレクトされること" do
      get admin_root_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
