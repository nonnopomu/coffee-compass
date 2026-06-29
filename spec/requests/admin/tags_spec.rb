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
      Tag.create!(
        name: "一覧確認タグ",
        category: :taste,
        display_order: 1,
        beginner_display_order: 1,
        is_active: true
      )

      sign_in admin
      get admin_tags_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("一覧確認タグ")
    end

    it "味わいタグは公式の大項目と小項目を表示し、古い無効タグは表示しないこと" do
      admin = create_user(role: :admin)
      parent_tag = Tag.create!(
        name: "花",
        category: :taste,
        display_order: 1,
        beginner_display_order: 1,
        is_active: true
      )
      Tag.create!(
        name: "ジャスミン",
        category: :taste,
        display_order: 2,
        is_active: true,
        parent: parent_tag
      )
      Tag.create!(
        name: "ローズ",
        category: :taste,
        display_order: 3,
        is_active: false,
        parent: parent_tag
      )
      Tag.create!(
        name: "古い味わいタグ",
        category: :taste,
        display_order: 99,
        is_active: false
      )

      sign_in admin
      get admin_tags_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("花")
      expect(response.body).to include("ジャスミン")
      expect(response.body).to include("ローズ")
      expect(response.body).not_to include("古い味わいタグ")
    end

    it "非アクティブなタグは一覧に表示しないこと" do
      admin = create_user(role: :admin)
      Tag.create!(name: "深煎り", category: :roast_level, display_order: 1, is_active: true)
      Tag.create!(name: "深入り", category: :roast_level, display_order: 2, is_active: false)

      sign_in admin
      get admin_tags_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("深煎り")
      expect(response.body).not_to include("深入り")
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

    it "カテゴリごとの次の表示順が初期表示されること" do
      admin = create_user(role: :admin)
      Tag.create!(name: "浅煎り", category: :roast_level, display_order: 30, is_active: true)

      sign_in admin
      get new_admin_tag_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('value="31"')
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

    it "味わいタグの小項目を登録できること" do
      admin = create_user(role: :admin)
      parent_tag = Tag.create!(
        name: "花",
        category: :taste,
        display_order: 1,
        beginner_display_order: 1,
        is_active: true
      )

      sign_in admin

      expect {
        post admin_tags_path, params: {
          tag: admin_tag_params(name: "ローズ", display_order: 2, parent_id: parent_tag.id)
        }
      }.to change(Tag, :count).by(1)

      expect(response).to redirect_to(admin_tags_path)
      expect(Tag.last.parent).to eq(parent_tag)
    end

    it "同じカテゴリ内で有効タグの表示順が重複する場合は登録できないこと" do
      admin = create_user(role: :admin)
      create_taste_tag(name: "既存タグ", display_order: 1)

      sign_in admin

      expect {
        post admin_tags_path, params: {
          tag: admin_tag_params(name: "重複表示順タグ", display_order: 1)
        }
      }.not_to change(Tag, :count)

      expect(response).to have_http_status(:unprocessable_content)
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
