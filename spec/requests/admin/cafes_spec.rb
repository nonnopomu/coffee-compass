require "rails_helper"

RSpec.describe "Admin::Cafes", type: :request do
  describe "GET /admin/cafes" do
    it "管理者はカフェ管理一覧を閲覧できること" do
      admin = create_user(role: :admin)
      create_cafe

      sign_in admin
      get admin_cafes_path

      expect(response).to have_http_status(:ok)
    end

    it "一般ユーザーはカフェ管理一覧を閲覧できないこと" do
      user = create_user

      sign_in user
      get admin_cafes_path

      expect(response).to redirect_to(root_path)
    end

    it "未ログインユーザーはログイン画面へリダイレクトされること" do
      get admin_cafes_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
