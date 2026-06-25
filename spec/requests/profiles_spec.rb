require "rails_helper"

RSpec.describe "Profiles", type: :request do
  describe "GET /profile/edit" do
    it "ログインユーザーはプロフィール編集画面を閲覧できること" do
      user = create_user

      sign_in user
      get edit_profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("views.profiles.edit.page_title"))
    end

    it "プロフィール編集フォームに入力補助と画像選択UIがあること" do
      user = create_user

      sign_in user
      get edit_profile_path

      html = Nokogiri::HTML(response.body)
      name_field = html.at_css('input[name="user[name]"]')
      avatar_field = html.at_css('input[name="user[avatar]"]')

      expect(name_field["required"]).to eq("required")
      expect(name_field["maxlength"]).to eq("50")
      expect(avatar_field["accept"]).to eq("image/jpeg,image/png,image/webp")
      expect(response.body).to include(I18n.t("views.profiles.edit.choose_avatar"))
      expect(response.body).not_to include("選択されていません")
    end

    it "未ログインユーザーはプロフィール編集画面を閲覧できないこと" do
      get edit_profile_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /profile" do
    it "ログインユーザーはユーザー名を更新できること" do
      user = create_user(name: "変更前")

      sign_in user
      patch profile_path, params: { user: { name: "変更後" } }

      expect(response).to redirect_to(mypage_path)
      expect(user.reload.name).to eq("変更後")
    end

    it "入力値が不正な場合は更新せず編集画面を再表示すること" do
      user = create_user(name: "変更前")

      sign_in user
      patch profile_path, params: { user: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.name).to eq("変更前")
    end

    it "プロフィール画像を添付できること" do
      user = create_user
      avatar = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.png"), "image/png")

      sign_in user
      patch profile_path, params: { user: { name: user.name, avatar: } }

      expect(response).to redirect_to(mypage_path)
      expect(user.reload.avatar).to be_attached
    end

    it "未ログインユーザーはプロフィールを更新できないこと" do
      patch profile_path, params: { user: { name: "変更後" } }

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
