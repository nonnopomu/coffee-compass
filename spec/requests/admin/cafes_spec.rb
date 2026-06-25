require "rails_helper"

RSpec.describe "Admin::Cafes", type: :request do
  def admin_cafe_params(**overrides)
    {
      prefecture: "東京都",
      name: "管理カフェ #{unique_suffix}",
      address: "東京都渋谷区管理1-1-1",
      google_maps_url: "https://maps.example.com/#{unique_suffix}",
      description: "管理画面から登録するカフェ",
      status: "published",
      tag_ids: []
    }.merge(overrides)
  end

  describe "GET /admin/cafes" do
    it "管理者はカフェ管理一覧を閲覧できること" do
      admin = create_user(role: :admin)
      create_cafe

      sign_in admin
      get admin_cafes_path

      expect(response).to have_http_status(:ok)
    end

    it "管理者はカフェ管理一覧でカフェ画像を確認できること" do
      admin = create_user(role: :admin)
      cafe = create_cafe(name: "管理画像カフェ")
      attach_valid_image(cafe, :image, filename: "cafe.png")

      sign_in admin
      get admin_cafes_path

      html = Nokogiri::HTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(html.at_css('img[alt="管理画像カフェ"]')).to be_present
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

  describe "GET /admin/cafes/new" do
    it "管理者はカフェ新規登録画面を閲覧できること" do
      admin = create_user(role: :admin)

      sign_in admin
      get new_admin_cafe_path

      expect(response).to have_http_status(:ok)
    end

    it "管理者はカフェ画像選択UIを確認できること" do
      admin = create_user(role: :admin)

      sign_in admin
      get new_admin_cafe_path

      html = Nokogiri::HTML(response.body)
      image_field = html.at_css('input[name="cafe[image]"]')

      expect(image_field["accept"]).to eq("image/jpeg,image/png,image/webp")
      expect(response.body).to include(I18n.t("views.admin.cafes.form.image_preview_placeholder"))
    end
  end

  describe "POST /admin/cafes" do
    it "管理者はカフェを登録できること" do
      admin = create_user(role: :admin)
      feature_tag = create_cafe_feature_tag

      sign_in admin

      expect {
        post admin_cafes_path, params: {
          cafe: admin_cafe_params(name: "登録確認カフェ", tag_ids: [ feature_tag.id ])
        }
      }.to change(Cafe, :count).by(1)

      expect(response).to redirect_to(admin_cafes_path)
      expect(Cafe.last.name).to eq("登録確認カフェ")
      expect(Cafe.last.tags).to include(feature_tag)
    end

    it "管理者はカフェ画像を添付して登録できること" do
      admin = create_user(role: :admin)
      image = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.png"), "image/png")

      sign_in admin

      expect {
        post admin_cafes_path, params: {
          cafe: admin_cafe_params(name: "画像付きカフェ", image:)
        }
      }.to change(Cafe, :count).by(1)

      expect(response).to redirect_to(admin_cafes_path)
      expect(Cafe.last.image).to be_attached
    end

    it "入力値が不正な場合は登録せず、新規登録画面を再表示すること" do
      admin = create_user(role: :admin)

      sign_in admin

      expect {
        post admin_cafes_path, params: { cafe: admin_cafe_params(name: "") }
      }.not_to change(Cafe, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "一般ユーザーはカフェを登録できないこと" do
      user = create_user

      sign_in user

      expect {
        post admin_cafes_path, params: { cafe: admin_cafe_params }
      }.not_to change(Cafe, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /admin/cafes/:id/edit" do
    it "管理者はカフェ編集画面を閲覧できること" do
      admin = create_user(role: :admin)
      cafe = create_cafe

      sign_in admin
      get edit_admin_cafe_path(cafe)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/cafes/:id" do
    it "管理者はカフェを更新できること" do
      admin = create_user(role: :admin)
      cafe = create_cafe(name: "更新前カフェ")

      sign_in admin
      patch admin_cafe_path(cafe), params: {
        cafe: admin_cafe_params(name: "更新後カフェ", status: "closed")
      }

      expect(response).to redirect_to(admin_cafes_path)
      expect(cafe.reload.name).to eq("更新後カフェ")
      expect(cafe).to be_closed
    end

    it "管理者はカフェ画像を添付して更新できること" do
      admin = create_user(role: :admin)
      cafe = create_cafe
      image = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.png"), "image/png")

      sign_in admin
      patch admin_cafe_path(cafe), params: {
        cafe: admin_cafe_params(image:)
      }

      expect(response).to redirect_to(admin_cafes_path)
      expect(cafe.reload.image).to be_attached
    end

    it "入力値が不正な場合は更新せず、編集画面を再表示すること" do
      admin = create_user(role: :admin)
      cafe = create_cafe(name: "更新前カフェ")

      sign_in admin
      patch admin_cafe_path(cafe), params: { cafe: admin_cafe_params(name: "") }

      expect(response).to have_http_status(:unprocessable_content)
      expect(cafe.reload.name).to eq("更新前カフェ")
    end
  end
end
