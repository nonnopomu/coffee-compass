require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "POST /users" do
    it "ユーザー登録できること" do
      expect {
        post user_registration_path, params: {
          user: {
            name: "登録ユーザー",
            email: "new-user@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it "ユーザー登録時に名前が保存されること" do
      post user_registration_path, params: {
        user: {
          name: "名前確認ユーザー",
          email: "named-user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }

      expect(User.last.name).to eq("名前確認ユーザー")
    end
  end

  describe "POST /users/sign_in" do
    it "ログインできること" do
      user = create_user(email: "login-user@example.com", password: "password")

      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password"
        }
      }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /users/sign_out" do
    it "ログアウトできること" do
      user = create_user

      sign_in user
      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
    end
  end
end
