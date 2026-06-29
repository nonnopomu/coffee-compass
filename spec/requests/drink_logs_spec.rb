require "rails_helper"

RSpec.describe "Drink logs", type: :request do
  def drink_log_params(cafe:, roast_level_tag:, taste_tags:, **overrides)
    # フォームのhidden fieldから送るcafe_idと、選択式のタグIDをまとめて再現する。
    {
      cafe_id: cafe.id,
      menu_name: "本日のコーヒー",
      drank_on: Date.current,
      roast_level_tag_id: roast_level_tag.id,
      memo: "香りがよかった",
      taste_tag_ids: taste_tags.map(&:id)
    }.merge(overrides)
  end

  def uploaded_image
    Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.png"), "image/png")
  end

  describe "GET /drink_logs/new" do
    it "ログインユーザーは画像選択UIを確認できること" do
      user = create_user

      sign_in user
      get new_drink_log_path

      html = Nokogiri::HTML(response.body)
      image_field = html.at_css('input[name="drink_log[image]"]')

      expect(response).to have_http_status(:ok)
      expect(image_field["accept"]).to eq("image/jpeg,image/png,image/webp")
      expect(response.body).to include(I18n.t("views.drink_logs.form.image_preview_placeholder"))
    end

    it "return_toをフォーム送信まで引き継ぐこと" do
      user = create_user

      sign_in user
      get new_drink_log_path(return_to: mypage_path)

      html = Nokogiri::HTML(response.body)
      return_to_field = html.at_css('input[name="return_to"]')

      expect(response).to have_http_status(:ok)
      expect(return_to_field["value"]).to eq(mypage_path)
    end

    it "初心者向け味わいタグは大項目だけを選択対象にすること" do
      user = create_user
      parent_tag = Tag.create!(
        category: :taste,
        name: "花",
        display_order: 1,
        beginner_display_order: 1,
        color_hex: "#EFB8C8",
        is_active: true
      )
      child_tag = Tag.create!(
        category: :taste,
        name: "ジャスミン",
        display_order: 2,
        parent: parent_tag,
        color_hex: "#FFFFFF",
        is_active: true
      )

      sign_in user
      get new_drink_log_path

      html = Nokogiri::HTML(response.body)
      parent_input = html.at_css(%(input[name="drink_log[taste_tag_ids][]"][value="#{parent_tag.id}"]))
      child_input = html.at_css(%(input[name="drink_log[taste_tag_ids][]"][value="#{child_tag.id}"]))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("views.drink_logs.form.taste_help"))
      expect(response.body).to include("花")
      expect(response.body).to include("ジャスミン")
      expect(parent_input).to be_present
      expect(child_input).to be_nil
    end
  end

  describe "POST /drink_logs" do
    it "ログインユーザーは飲んだログを投稿できること" do
      user = create_user
      cafe = create_cafe(status: :published)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user

      expect {
        post drink_logs_path, params: {
          drink_log: drink_log_params(
            cafe:,
            roast_level_tag:,
            taste_tags: [ taste_tag ]
          )
        }
      }.to change(user.drink_logs, :count).by(1)

      expect(response).to redirect_to(cafe_path(cafe, tab: "logs"))
    end

    it "ログインユーザーは画像を添付して飲んだログを投稿できること" do
      user = create_user
      cafe = create_cafe(status: :published)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user

      expect {
        post drink_logs_path, params: {
          drink_log: drink_log_params(
            cafe:,
            roast_level_tag:,
            taste_tags: [ taste_tag ],
            image: uploaded_image
          )
        }
      }.to change(user.drink_logs, :count).by(1)

      expect(response).to redirect_to(cafe_path(cafe, tab: "logs"))
      expect(DrinkLog.last.image).to be_attached
    end

    it "return_toが指定された場合は投稿後に指定された戻り先へ遷移すること" do
      user = create_user
      cafe = create_cafe(status: :published)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user

      expect {
        post drink_logs_path, params: {
          return_to: mypage_path,
          drink_log: drink_log_params(
            cafe:,
            roast_level_tag:,
            taste_tags: [ taste_tag ]
          )
        }
      }.to change(user.drink_logs, :count).by(1)

      expect(response).to redirect_to(mypage_path)
    end

    it "return_toに外部URLが指定された場合は外部URLへ遷移しないこと" do
      user = create_user
      cafe = create_cafe(status: :published)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user

      expect {
        post drink_logs_path, params: {
          return_to: "//evil.example.com/phishing",
          drink_log: drink_log_params(
            cafe:,
            roast_level_tag:,
            taste_tags: [ taste_tag ]
          )
        }
      }.to change(user.drink_logs, :count).by(1)

      expect(response).to redirect_to(cafe_path(cafe, tab: "logs"))
    end

    it "入力値が不正な場合は投稿できず、作成画面を再表示すること" do
      user = create_user
      cafe = create_cafe(status: :published)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user

      expect {
        post drink_logs_path, params: {
          drink_log: drink_log_params(
            cafe:,
            roast_level_tag:,
            taste_tags: [ taste_tag ],
            menu_name: ""
          )
        }
      }.not_to change(DrinkLog, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "入力値が不正な場合も初心者向け味わいタグを再表示すること" do
      user = create_user
      cafe = create_cafe(status: :published)
      roast_level_tag = create_roast_level_tag
      parent_tag = Tag.create!(
        category: :taste,
        name: "ベリー",
        display_order: 1,
        beginner_display_order: 1,
        color_hex: "#D64550",
        is_active: true
      )
      child_tag = Tag.create!(
        category: :taste,
        name: "ストロベリー",
        display_order: 2,
        parent: parent_tag,
        color_hex: "#D64550",
        is_active: true
      )

      sign_in user
      post drink_logs_path, params: {
        drink_log: drink_log_params(
          cafe:,
          roast_level_tag:,
          taste_tags: [ parent_tag ],
          menu_name: ""
        )
      }

      html = Nokogiri::HTML(response.body)
      parent_input = html.at_css(%(input[name="drink_log[taste_tag_ids][]"][value="#{parent_tag.id}"]))
      child_input = html.at_css(%(input[name="drink_log[taste_tag_ids][]"][value="#{child_tag.id}"]))

      expect(response).to have_http_status(:unprocessable_content)
      expect(parent_input).to be_present
      expect(child_input).to be_nil
    end

    it "未ログインユーザーは投稿できないこと" do
      cafe = create_cafe(status: :published)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      expect {
        post drink_logs_path, params: {
          drink_log: drink_log_params(
            cafe:,
            roast_level_tag:,
            taste_tags: [ taste_tag ]
          )
        }
      }.not_to change(DrinkLog, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /drink_logs/:id" do
    it "飲んだログ詳細を閲覧できること" do
      drink_log = create_drink_log(menu_name: "詳細確認ログ")

      get drink_log_path(drink_log)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("詳細確認ログ")
    end

    it "飲んだログ画像がある場合は詳細に表示されること" do
      drink_log = create_drink_log(menu_name: "画像付き詳細ログ")
      attach_valid_image(drink_log, :image, filename: "drink_log.png")

      get drink_log_path(drink_log)

      html = Nokogiri::HTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(html.at_css('img[alt="画像付き詳細ログ"]')).to be_present
    end

    it "投稿者本人には編集・削除の導線が表示されること" do
      user = create_user
      drink_log = create_drink_log(user:)

      sign_in user
      get drink_log_path(drink_log)

      expect(response.body).to include("編集する")
      expect(response.body).to include("削除する")
    end

    it "投稿者本人以外には編集・削除の導線が表示されないこと" do
      other_user = create_user
      drink_log = create_drink_log

      sign_in other_user
      get drink_log_path(drink_log)

      expect(response.body).not_to include("編集する")
      expect(response.body).not_to include("削除する")
    end

    it "不正な戻り先URLをリンクに使わないこと" do
      drink_log = create_drink_log(cafe: create_cafe(status: :published))

      # return_toに外部サイト風の値が来ても、画面内リンクへ混ぜないことを確認する。
      get drink_log_path(drink_log), params: { return_to: "//evil.example.com/phishing" }

      expect(response.body).not_to include("//evil.example.com")
    end
  end

  describe "GET /drink_logs/:id/edit" do
    it "投稿者本人は編集画面を閲覧できること" do
      user = create_user
      drink_log = create_drink_log(user:)

      sign_in user
      get edit_drink_log_path(drink_log)

      expect(response).to have_http_status(:ok)
    end

    it "投稿者本人は画像選択UIを確認できること" do
      user = create_user
      drink_log = create_drink_log(user:)

      sign_in user
      get edit_drink_log_path(drink_log)

      html = Nokogiri::HTML(response.body)
      image_field = html.at_css('input[name="drink_log[image]"]')

      expect(response).to have_http_status(:ok)
      expect(image_field["accept"]).to eq("image/jpeg,image/png,image/webp")
      expect(response.body).to include(I18n.t("views.drink_logs.form.image_preview_placeholder"))
    end

    it "画像付きのログでは写真削除ボタンを確認できること" do
      user = create_user
      drink_log = create_drink_log(user:)
      attach_valid_image(drink_log, :image, filename: "drink_log.png")

      sign_in user
      get edit_drink_log_path(drink_log)

      html = Nokogiri::HTML(response.body)
      remove_image_field = html.at_css('input[name="drink_log[remove_image]"]')

      expect(response).to have_http_status(:ok)
      expect(remove_image_field["value"]).to eq("0")
      expect(response.body).to include(I18n.t("views.drink_logs.form.remove_image"))
    end

    it "一般ユーザーは他人の編集画面を閲覧できないこと" do
      user = create_user
      drink_log = create_drink_log

      sign_in user
      get edit_drink_log_path(drink_log)

      expect(response).to redirect_to(drink_log_path(drink_log))
    end

    it "管理者でも他人の編集画面は閲覧できないこと" do
      admin = create_user(role: :admin)
      drink_log = create_drink_log

      sign_in admin
      get edit_drink_log_path(drink_log)

      expect(response).to redirect_to(drink_log_path(drink_log))
    end
  end

  describe "PATCH /drink_logs/:id" do
    it "投稿者本人は飲んだログを更新できること" do
      user = create_user
      drink_log = create_drink_log(user:)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user
      patch drink_log_path(drink_log), params: {
        drink_log: drink_log_params(
          cafe: drink_log.cafe,
          roast_level_tag:,
          taste_tags: [ taste_tag ],
          menu_name: "更新後のログ"
        )
      }

      expect(response).to redirect_to(drink_log_path(drink_log))
      expect(drink_log.reload.menu_name).to eq("更新後のログ")
    end

    it "投稿者本人は画像を添付して飲んだログを更新できること" do
      user = create_user
      drink_log = create_drink_log(user:)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user
      patch drink_log_path(drink_log), params: {
        drink_log: drink_log_params(
          cafe: drink_log.cafe,
          roast_level_tag:,
          taste_tags: [ taste_tag ],
          image: uploaded_image
        )
      }

      expect(response).to redirect_to(drink_log_path(drink_log))
      expect(drink_log.reload.image).to be_attached
    end

    it "投稿者本人は飲んだログ画像を削除できること" do
      user = create_user
      drink_log = create_drink_log(user:)
      attach_valid_image(drink_log, :image, filename: "drink_log.png")
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user
      patch drink_log_path(drink_log), params: {
        drink_log: drink_log_params(
          cafe: drink_log.cafe,
          roast_level_tag:,
          taste_tags: [ taste_tag ],
          remove_image: "1"
        )
      }

      expect(response).to redirect_to(drink_log_path(drink_log))
      expect(drink_log.reload.image).not_to be_attached
    end

    it "入力値が不正な場合は飲んだログ画像を削除しないこと" do
      user = create_user
      drink_log = create_drink_log(user:)
      attach_valid_image(drink_log, :image, filename: "drink_log.png")
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user
      patch drink_log_path(drink_log), params: {
        drink_log: drink_log_params(
          cafe: drink_log.cafe,
          roast_level_tag:,
          taste_tags: [ taste_tag ],
          menu_name: "",
          remove_image: "1"
        )
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(drink_log.reload.image).to be_attached
    end

    it "入力値が不正な場合は更新せず、編集画面を再表示すること" do
      user = create_user
      drink_log = create_drink_log(user:, menu_name: "更新前のログ")
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user
      patch drink_log_path(drink_log), params: {
        drink_log: drink_log_params(
          cafe: drink_log.cafe,
          roast_level_tag:,
          taste_tags: [ taste_tag ],
          menu_name: ""
        )
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(drink_log.reload.menu_name).to eq("更新前のログ")
    end

    it "一般ユーザーは他人の飲んだログを更新できないこと" do
      user = create_user
      drink_log = create_drink_log(menu_name: "他人のログ")
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user

      expect {
        patch drink_log_path(drink_log), params: {
          drink_log: drink_log_params(
            cafe: drink_log.cafe,
            roast_level_tag:,
            taste_tags: [ taste_tag ],
            menu_name: "不正な更新"
          )
        }
      }.not_to change { drink_log.reload.menu_name }

      expect(response).to redirect_to(drink_log_path(drink_log))
    end

    it "管理者でも他人の飲んだログを更新できないこと" do
      admin = create_user(role: :admin)
      drink_log = create_drink_log(menu_name: "他人のログ")
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in admin

      expect {
        patch drink_log_path(drink_log), params: {
          drink_log: drink_log_params(
            cafe: drink_log.cafe,
            roast_level_tag:,
            taste_tags: [ taste_tag ],
            menu_name: "管理者による更新"
          )
        }
      }.not_to change { drink_log.reload.menu_name }

      expect(response).to redirect_to(drink_log_path(drink_log))
    end

    it "更新時にcafe_idを送っても紐づくカフェは変更されないこと" do
      user = create_user
      original_cafe = create_cafe(status: :published)
      other_cafe = create_cafe(status: :published)
      drink_log = create_drink_log(user:, cafe: original_cafe)
      roast_level_tag = create_roast_level_tag
      taste_tag = create_taste_tag

      sign_in user
      patch drink_log_path(drink_log), params: {
        drink_log: drink_log_params(
          cafe: other_cafe,
          roast_level_tag:,
          taste_tags: [ taste_tag ]
        )
      }

      expect(drink_log.reload.cafe).to eq(original_cafe)
    end
  end

  describe "DELETE /drink_logs/:id" do
    it "投稿者本人は飲んだログを削除でき、指定された戻り先へ遷移すること" do
      user = create_user
      drink_log = create_drink_log(user:)

      sign_in user

      expect {
        delete drink_log_path(drink_log), params: { return_to: mypage_path }
      }.to change(DrinkLog, :count).by(-1)

      expect(response).to redirect_to(mypage_path)
    end

    it "戻り先がない場合はカフェ詳細のみんなのログタブへ遷移すること" do
      user = create_user
      cafe = create_cafe(status: :published)
      drink_log = create_drink_log(user:, cafe:)

      sign_in user
      delete drink_log_path(drink_log)

      expect(response).to redirect_to(cafe_path(cafe, tab: "logs"))
    end

    it "不正な戻り先URLが指定された場合は外部URLへ遷移しないこと" do
      user = create_user
      cafe = create_cafe(status: :published)
      drink_log = create_drink_log(user:, cafe:)

      sign_in user
      delete drink_log_path(drink_log), params: { return_to: "//evil.example.com/phishing" }

      expect(response).to redirect_to(cafe_path(cafe, tab: "logs"))
    end

    it "一般ユーザーは他人の飲んだログを削除できないこと" do
      user = create_user
      drink_log = create_drink_log

      sign_in user

      expect {
        delete drink_log_path(drink_log)
      }.not_to change(DrinkLog, :count)

      expect(response).to redirect_to(drink_log_path(drink_log))
    end

    it "管理者でも他人の飲んだログを削除できないこと" do
      admin = create_user(role: :admin)
      drink_log = create_drink_log

      sign_in admin

      expect {
        delete drink_log_path(drink_log)
      }.not_to change(DrinkLog, :count)

      expect(response).to redirect_to(drink_log_path(drink_log))
    end
  end
end
