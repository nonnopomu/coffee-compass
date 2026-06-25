require "rails_helper"

RSpec.describe DrinkLog, type: :model do
  describe "バリデーション" do
    it "有効な属性で作成できること" do
      expect(build_drink_log).to be_valid
    end

    it "メニュー名が必須であること" do
      drink_log = build_drink_log(menu_name: "")

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:menu_name]).to be_present
    end

    it "メニュー名が100文字以内であること" do
      drink_log = build_drink_log(menu_name: "a" * 101)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:menu_name]).to be_present
    end

    it "飲んだ日が必須であること" do
      drink_log = build_drink_log(drank_on: nil)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:drank_on]).to be_present
    end

    it "メモが200文字以内であること" do
      drink_log = build_drink_log(memo: "a" * 201)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:memo]).to be_present
    end

    it "ユーザーが必須であること" do
      drink_log = build_drink_log(user: nil)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:user]).to be_present
    end

    it "カフェが必須であること" do
      drink_log = build_drink_log(cafe: nil)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:cafe]).to be_present
    end

    it "焙煎度タグが必須であること" do
      drink_log = build_drink_log(roast_level_tag: nil)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:roast_level_tag]).to be_present
    end

    it "焙煎度タグには焙煎度カテゴリのタグだけを選べること" do
      drink_log = build_drink_log(roast_level_tag: create_taste_tag)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:roast_level_tag]).to be_present
    end

    it "提供スタイルタグが必須であること" do
      drink_log = build_drink_log(brew_method_tag: nil)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:brew_method_tag]).to be_present
    end

    it "提供スタイルタグには提供スタイルカテゴリのタグだけを選べること" do
      drink_log = build_drink_log(brew_method_tag: create_taste_tag)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:brew_method_tag]).to be_present
    end

    it "味わいタグが1つ以上必要であること" do
      drink_log = build_drink_log(taste_tag: nil)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:base]).to be_present
    end

    it "飲んだログ画像はJPEG、PNG、WebP形式を添付できること" do
      {
        "image/jpeg" => "drink_log.jpg",
        "image/png" => "drink_log.png",
        "image/webp" => "drink_log.webp"
      }.each do |content_type, filename|
        drink_log = build_drink_log

        attach_valid_image(drink_log, :image, content_type:, filename:)

        expect(drink_log).to be_valid
      end
    end

    it "飲んだログ画像に許可されていない形式は添付できないこと" do
      drink_log = build_drink_log

      attach_invalid_type_image(drink_log, :image)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:image]).to include(I18n.t("activerecord.errors.messages.invalid_image_type"))
    end

    it "飲んだログ画像は5MB以下であること" do
      drink_log = build_drink_log

      attach_oversized_image(drink_log, :image)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:image]).to include(I18n.t("activerecord.errors.messages.image_too_large", max_size: "5MB"))
    end
  end

  describe "ステータス" do
    it "初期値がpublishedであること" do
      expect(described_class.new).to be_published
    end

    it "publishedとhiddenを扱えること" do
      expect(described_class.statuses).to include("published" => 0, "hidden" => 1)
    end
  end

  describe "関連付け" do
    it "ユーザーとカフェに紐づくこと" do
      user = create_user
      cafe = create_cafe
      drink_log = create_drink_log(user:, cafe:)

      expect(drink_log.user).to eq(user)
      expect(drink_log.cafe).to eq(cafe)
    end

    it "焙煎度タグと提供スタイルタグに紐づくこと" do
      roast_level_tag = create_roast_level_tag
      brew_method_tag = create_brew_method_tag
      drink_log = create_drink_log(roast_level_tag:, brew_method_tag:)

      expect(drink_log.roast_level_tag).to eq(roast_level_tag)
      expect(drink_log.brew_method_tag).to eq(brew_method_tag)
    end

    it "複数の味わいタグに紐づけられること" do
      first_taste_tag = create_taste_tag(name: "フルーティー")
      second_taste_tag = create_taste_tag(name: "甘い")
      drink_log = build_drink_log(taste_tag: first_taste_tag)
      drink_log.drink_log_taste_tags.build(tag: second_taste_tag)
      drink_log.save!

      expect(drink_log.taste_tags).to contain_exactly(first_taste_tag, second_taste_tag)
    end

    it "飲んだログ削除時に味わいタグ中間レコードも削除されること" do
      drink_log = create_drink_log

      expect { drink_log.destroy }.to change(DrinkLogTasteTag, :count).by(-1)
    end
  end
end
