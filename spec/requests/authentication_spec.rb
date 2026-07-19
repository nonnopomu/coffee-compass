require "rails_helper"

RSpec.describe "Authentication", type: :request do
  def set_cookie_header
    Array(response.headers["Set-Cookie"]).join("\n")
  end

  describe "GET /users/sign_in" do
    it "ログインフォームに必須入力とパスワード最小文字数の入力補助があること" do
      get new_user_session_path

      html = Nokogiri::HTML(response.body)
      email_field = html.at_css('input[name="user[email]"]')
      password_field = html.at_css('input[name="user[password]"]')
      remember_me_field = html.at_css('input[type="checkbox"][name="user[remember_me]"]')
      login_form = html.at_css('form[action="/users/sign_in"]')
      login_button = login_form.at_css('input[type="submit"]')

      expect(email_field["required"]).to eq("required")
      expect(password_field["required"]).to eq("required")
      expect(password_field["minlength"]).to eq(Devise.password_length.min.to_s)
      expect(remember_me_field["type"]).to eq("checkbox")
      expect(login_form["data-controller"]).to include("form-submit")
      expect(login_form["data-action"]).to include("form-submit#disable")
      expect(login_button["data-form-submit-target"]).to eq("submitButton")
      expect(response.body).to include(I18n.t("views.devise.sessions.new.remember_me"))
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
      sign_up_form = html.at_css('form[action="/users"]')
      sign_up_button = sign_up_form.at_css('input[type="submit"]')

      expect(name_field["required"]).to eq("required")
      expect(email_field["required"]).to eq("required")
      expect(password_field["required"]).to eq("required")
      expect(password_field["minlength"]).to eq(Devise.password_length.min.to_s)
      expect(password_confirmation_field["required"]).to eq("required")
      expect(password_confirmation_field["minlength"]).to eq(Devise.password_length.min.to_s)
      expect(sign_up_form["data-controller"]).to include("form-submit")
      expect(sign_up_form["data-action"]).to include("form-submit#disable")
      expect(sign_up_button["data-form-submit-target"]).to eq("submitButton")
    end
  end

  describe "GET /users/password/new" do
    it "パスワード再設定フォームに必須入力の入力補助があること" do
      get new_user_password_path

      html = Nokogiri::HTML(response.body)
      email_field = html.at_css('input[name="user[email]"]')
      password_reset_form = html.at_css('form[action="/users/password"]')
      password_reset_button = password_reset_form.at_css('input[type="submit"]')

      expect(email_field["required"]).to eq("required")
      expect(password_reset_form["data-controller"]).to include("form-submit")
      expect(password_reset_form["data-action"]).to include("form-submit#disable")
      expect(password_reset_button["data-form-submit-target"]).to eq("submitButton")
    end
  end

  describe "GET /users/edit" do
    it "ログインユーザーがアカウント設定画面を閲覧できること" do
      user = create_user

      sign_in user
      get edit_user_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("views.devise.registrations.edit.page_title"))
      expect(response.body).to include(user.email)
    end

    it "アカウント更新フォームに二重送信防止用のdata属性があること" do
      user = create_user

      sign_in user
      get edit_user_registration_path

      html = Nokogiri::HTML(response.body)
      account_form = html.at_css('form[action="/users"]')
      update_button = account_form.at_css('input[type="submit"]')

      expect(account_form["data-controller"]).to include("form-submit")
      expect(account_form["data-action"]).to include("form-submit#disable")
      expect(update_button["data-form-submit-target"]).to eq("submitButton")
    end

    it "通常ユーザーにはメールアドレス変更用の現在のパスワード入力が表示されること" do
      user = create_user

      sign_in user
      get edit_user_registration_path

      html = Nokogiri::HTML(response.body)

      expect(html.at_css('input[name="user[current_password]"]')).to be_present
      expect(html.at_css('input[name="user[password]"]')).to be_nil
      expect(html.at_css('input[name="user[password_confirmation]"]')).to be_nil
    end

    it "Google連携ユーザーはメールアドレスを画面上で変更できないこと" do
      user = create_user(email: "google-view@example.com")
      user.update!(provider: "google_oauth2", uid: "google-view-uid")

      sign_in user
      get edit_user_registration_path

      html = Nokogiri::HTML(response.body)
      email_field = html.at_css('input[name="user[email]"]')

      expect(email_field["disabled"]).to eq("disabled")
      expect(html.at_css('input[name="user[current_password]"]')).to be_nil
      expect(response.body).to include(I18n.t("views.devise.registrations.edit.google_email_locked"))
    end

    it "アカウント削除は確認チェックを入れるまでボタンが無効であること" do
      user = create_user

      sign_in user
      get edit_user_registration_path

      html = Nokogiri::HTML(response.body)
      checkbox = html.at_css('input[name="confirm_account_deletion"]')
      delete_button = html.at_css('input[type="submit"][value="アカウントを削除する"]')

      expect(checkbox).to be_present
      expect(checkbox["required"]).to eq("required")
      expect(delete_button["disabled"]).to eq("disabled")
    end

    it "未ログインユーザーはログイン画面へリダイレクトされること" do
      get edit_user_registration_path

      expect(response).to redirect_to(new_user_session_path)
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

  describe "PATCH /users" do
    it "通常ユーザーは現在のパスワードを入力するとメールアドレスを変更できること" do
      user = create_user(email: "before-change@example.com", password: "password")

      sign_in user
      patch user_registration_path, params: {
        user: {
          email: "after-change@example.com",
          current_password: "password"
        }
      }

      expect(user.reload.email).to eq("after-change@example.com")
      expect(response).to redirect_to(root_path)
    end

    it "通常ユーザーは現在のパスワードがないとメールアドレスを変更できないこと" do
      user = create_user(email: "no-password-before@example.com", password: "password")

      sign_in user
      patch user_registration_path, params: {
        user: {
          email: "no-password-after@example.com"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.email).to eq("no-password-before@example.com")
    end

    it "Google連携ユーザーはPATCHで送られてもメールアドレスを変更できないこと" do
      user = create_user(email: "google-patch-before@example.com")
      user.update!(provider: "google_oauth2", uid: "google-patch-uid")

      sign_in user
      patch user_registration_path, params: {
        user: {
          email: "google-patch-after@example.com"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.email).to eq("google-patch-before@example.com")
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

    it "ログイン状態を保持する場合はRemember me cookieを発行すること" do
      user = create_user(email: "remember-login@example.com", password: "password")

      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password",
          remember_me: "1"
        }
      }

      expect(response).to redirect_to(root_path)
      expect(set_cookie_header).to include("remember_user_token")
      expect(user.reload.remember_created_at).to be_present
    end

    it "ログイン状態を保持しない場合はRemember me cookieを発行しないこと" do
      user = create_user(email: "session-only-login@example.com", password: "password")

      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password",
          remember_me: "0"
        }
      }

      expect(response).to redirect_to(root_path)
      expect(set_cookie_header).not_to include("remember_user_token")
      expect(user.reload.remember_created_at).to be_nil
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

    it "Googleログイン後にRemember me cookieを発行すること" do
      post user_google_oauth2_omniauth_authorize_path
      follow_redirect!

      user = User.find_by!(email: "oauth-user@example.com")

      expect(set_cookie_header).to include("remember_user_token")
      expect(user.remember_created_at).to be_present
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

  describe "DELETE /users" do
    it "確認チェックがない場合はアカウントを削除できないこと" do
      user = create_user

      sign_in user

      expect {
        delete user_registration_path
      }.not_to change(User, :count)

      expect(response).to redirect_to(edit_user_registration_path)
      expect(flash[:alert]).to eq(I18n.t("flash.registrations.delete_confirmation_required"))
    end

    it "確認チェックがある場合はアカウントを削除できること" do
      user = create_user

      sign_in user

      expect {
        delete user_registration_path, params: { confirm_account_deletion: "1" }
      }.to change(User, :count).by(-1)

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

    it "ログアウト時にRemember me cookieを削除すること" do
      user = create_user(email: "remember-sign-out@example.com", password: "password")

      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password",
          remember_me: "1"
        }
      }

      expect(set_cookie_header).to include("remember_user_token")

      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
      expect(set_cookie_header).to include("remember_user_token=;")
    end
  end
end
