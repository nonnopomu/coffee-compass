require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "GET /users/sign_in" do
    it "ログインフォームに必須入力とパスワード最小文字数の入力補助があること" do
      get new_user_session_path

      html = Nokogiri::HTML(response.body)
      email_field = html.at_css('input[name="user[email]"]')
      password_field = html.at_css('input[name="user[password]"]')

      expect(email_field["required"]).to eq("required")
      expect(password_field["required"]).to eq("required")
      expect(password_field["minlength"]).to eq(Devise.password_length.min.to_s)
    end
  end

  describe "GET /users/sign_up" do
    it "新規登録フォームに必須入力とパスワード最小文字数の入力補助があること" do
      get new_user_registration_path

      html = Nokogiri::HTML(response.body)
      name_field = html.at_css('input[name="user[name]"]')
      email_field = html.at_css('input[name="user[email]"]')
      password_field = html.at_css('input[name="user[password]"]')
      password_confirmation_field = html.at_css('input[name="user[password_confirmation]"]')

      expect(name_field["required"]).to eq("required")
      expect(email_field["required"]).to eq("required")
      expect(password_field["required"]).to eq("required")
      expect(password_field["minlength"]).to eq(Devise.password_length.min.to_s)
      expect(password_confirmation_field["required"]).to eq("required")
      expect(password_confirmation_field["minlength"]).to eq(Devise.password_length.min.to_s)
    end
  end

  describe "GET /users/password/new" do
    it "パスワード再設定フォームに必須入力の入力補助があること" do
      get new_user_password_path

      html = Nokogiri::HTML(response.body)
      email_field = html.at_css('input[name="user[email]"]')

      expect(email_field["required"]).to eq("required")
    end
  end

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

    it "return_toが指定されている場合は登録後に指定ページへリダイレクトされること" do
      cafe = create_cafe(status: :published)

      post user_registration_path, params: {
        return_to: cafe_path(cafe),
        user: {
          name: "戻り先確認ユーザー",
          email: "return-sign-up@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }

      expect(response).to redirect_to(cafe_path(cafe))
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

    it "return_toが指定されている場合はログイン後に指定ページへリダイレクトされること" do
      user = create_user(email: "return-login@example.com", password: "password")
      cafe = create_cafe(status: :published)

      post user_session_path, params: {
        return_to: cafe_path(cafe),
        user: {
          email: user.email,
          password: "password"
        }
      }

      expect(response).to redirect_to(cafe_path(cafe))
    end

    it "return_toに外部URLが指定されている場合はログイン後にトップページへリダイレクトされること" do
      user = create_user(email: "safe-login@example.com", password: "password")

      post user_session_path, params: {
        return_to: "//evil.example.com/phishing",
        user: {
          email: user.email,
          password: "password"
        }
      }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /users/auth/google_oauth2" do
    let(:google_auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "request-google-uid",
        info: {
          email: "oauth-user@example.com",
          name: "OAuthユーザー"
        }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:google_oauth2] = google_auth
    end

    after do
      OmniAuth.config.mock_auth[:google_oauth2] = nil
      OmniAuth.config.test_mode = false
    end

    it "Google認証情報からユーザー登録とログインができること" do
      expect {
        post user_google_oauth2_omniauth_authorize_path
        follow_redirect!
      }.to change(User, :count).by(1)

      user = User.last

      expect(user.email).to eq("oauth-user@example.com")
      expect(user.name).to eq("OAuthユーザー")
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("request-google-uid")
      expect(response).to redirect_to(root_path)
    end

    it "同じメールアドレスの通常ユーザーが存在する場合は既存ユーザーでログインできること" do
      existing_user = create_user(email: "oauth-user@example.com", name: "編集済みユーザー")

      expect {
        post user_google_oauth2_omniauth_authorize_path
        follow_redirect!
      }.not_to change(User, :count)

      existing_user.reload
      expect(existing_user.provider).to eq("google_oauth2")
      expect(existing_user.uid).to eq("request-google-uid")
      expect(existing_user.name).to eq("編集済みユーザー")
      expect(response).to redirect_to(root_path)
    end

    it "ログイン必須ページで保存された戻り先がある場合はGoogleログイン後に元ページへ戻ること" do
      get mypage_path

      expect(response).to redirect_to(new_user_session_path)

      post user_google_oauth2_omniauth_authorize_path
      follow_redirect!

      expect(response).to redirect_to(mypage_path)
    end

    it "return_toが指定されている場合はGoogleログイン後に指定ページへリダイレクトされること" do
      cafe = create_cafe(status: :published)

      post user_google_oauth2_omniauth_authorize_path(return_to: cafe_path(cafe))
      follow_redirect!

      expect(response).to redirect_to(cafe_path(cafe))
    end

    it "return_toに外部URLが指定されている場合はGoogleログイン後にトップページへリダイレクトされること" do
      post user_google_oauth2_omniauth_authorize_path(return_to: "//evil.example.com/phishing")
      follow_redirect!

      expect(response).to redirect_to(root_path)
    end

    it "Google認証情報を保存できない場合はログイン画面へ戻ること" do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "invalid-google-uid",
        info: {
          email: "invalid-oauth-user@example.com",
          name: "a" * 51
        }
      )

      expect {
        post user_google_oauth2_omniauth_authorize_path
        follow_redirect!
      }.not_to change(User, :count)

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq(I18n.t("flash.omniauth.failure"))
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
