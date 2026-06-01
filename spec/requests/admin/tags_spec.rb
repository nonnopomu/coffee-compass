require "rails_helper"

RSpec.describe "Admin::Tags", type: :request do
  def admin_tag_params(**overrides)
    {
      name: "テストタグ #{unique_suffix}",
      category: "taste",
      display_order: 1,
      is_active: "1"
    }.merge(overrides)
  end

  describe "GET /admin/tags" do
    it "管理者はタグ管理一覧を閲覧できること" do
      admin = create_user(role: :admin)
      create_taste_tag(name: "一覧確認タグ")

      sign_in admin
      get admin_tags_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("一覧確認タグ")
    end

    it "一般ユーザーはタグ管理一覧を閲覧できないこと" do
      user = create_user

      sign_in user
      get admin_tags_path

      expect(response).to redirect_to(root_path)
    end

    it "未ログインユーザーはログイン画面へリダイレクトされること" do
      get admin_tags_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /admin/tags/new" do
    it "管理者はタグ新規作成画面を閲覧できること" do
      admin = create_user(role: :admin)

      sign_in admin
      get new_admin_tag_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/tags" do
    it "管理者はタグを登録できること" do
      admin = create_user(role: :admin)

      sign_in admin

      expect {
        post admin_tags_path, params: { tag: admin_tag_params(name: "登録タグ") }
      }.to change(Tag, :count).by(1)

      expect(response).to redirect_to(admin_tags_path)
      expect(Tag.last.name).to eq("登録タグ")
    end

    it "入力値が不正な場合は登録せず、新規作成画面を再表示すること" do
      admin = create_user(role: :admin)

      sign_in admin

      expect {
        post admin_tags_path, params: { tag: admin_tag_params(name: "") }
      }.not_to change(Tag, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /admin/tags/:id/edit" do
    it "管理者はタグ編集画面を閲覧できること" do
      admin = create_user(role: :admin)
      tag = create_taste_tag

      sign_in admin
      get edit_admin_tag_path(tag)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/tags/:id" do
    it "管理者はタグを更新できること" do
      admin = create_user(role: :admin)
      tag = create_taste_tag(name: "更新前タグ")

      sign_in admin
      patch admin_tag_path(tag), params: { tag: admin_tag_params(name: "更新後タグ") }

      expect(response).to redirect_to(admin_tags_path)
      expect(tag.reload.name).to eq("更新後タグ")
    end

    it "入力値が不正な場合は更新せず、編集画面を再表示すること" do
      admin = create_user(role: :admin)
      tag = create_taste_tag(name: "更新前タグ")

      sign_in admin
      patch admin_tag_path(tag), params: { tag: admin_tag_params(name: "") }

      expect(response).to have_http_status(:unprocessable_content)
      expect(tag.reload.name).to eq("更新前タグ")
    end
  end
end
