require "rails_helper"

RSpec.describe "Users", type: :request do
  def create_home_brew_drink_log(user:, **attributes)
    build_drink_log(user:, cafe: nil, **attributes).tap do |drink_log|
      drink_log.brewed_at_home = true
      drink_log.save!
    end
  end

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

    it "自宅記録がある公開プロフィールを閲覧できること" do
      user = create_user
      create_drink_log(user:)
      home_brew_log = create_home_brew_drink_log(user:, menu_name: "自宅プロフィールログ")

      get user_path(user)

      html = Nokogiri::HTML(response.body)
      visited_cafes_card = html.css("div").find do |node|
        node.element_children.any? { |child| child.name == "p" && child.text.strip == I18n.t("views.users.show.visited_cafes") }
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(home_brew_log.menu_name)
      expect(response.body).to include(I18n.t("views.drink_logs.home_brewed_place"))
      expect(visited_cafes_card.css("p").last.text.strip).to eq("1")
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
