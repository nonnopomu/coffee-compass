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

    it "自宅記録でない場合はカフェが必須であること" do
      drink_log = build_drink_log(cafe: nil)

      expect(drink_log).not_to be_valid
      expect(drink_log.errors[:cafe]).to be_present
    end

    it "自宅記録の場合はカフェなしで作成できること" do
      drink_log = build_drink_log(cafe: nil)
      drink_log.brewed_at_home = true

      expect(drink_log).to be_valid
    end

    it "自宅記録の場合は指定されたカフェが保存前に解除されること" do
      drink_log = build_drink_log
      drink_log.brewed_at_home = true

      expect { drink_log.valid? }.to change(drink_log, :cafe).to(nil)
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

  describe "#aggregated_taste_tags" do
    it "大項目タグはそのまま集計対象として返すこと" do
      parent_tag = create_taste_tag(name: "花")
      drink_log = create_drink_log(taste_tag: parent_tag)

      expect(drink_log.aggregated_taste_tags).to contain_exactly(parent_tag)
    end

    it "同じ親を持つ小項目タグは親タグ1つにまとめること" do
      parent_tag = create_taste_tag(name: "花")
      jasmine_tag = create_taste_tag(name: "ジャスミン", parent: parent_tag)
      chamomile_tag = create_taste_tag(name: "カモミール", parent: parent_tag)
      drink_log = build_drink_log(taste_tag: jasmine_tag)
      drink_log.drink_log_taste_tags.build(tag: chamomile_tag, position: 2)
      drink_log.save!

      expect(drink_log.aggregated_taste_tags).to contain_exactly(parent_tag)
    end

    it "異なる親を持つ小項目タグはそれぞれの親タグを返すこと" do
      floral_tag = create_taste_tag(name: "花")
      berry_tag = create_taste_tag(name: "ベリー")
      jasmine_tag = create_taste_tag(name: "ジャスミン", parent: floral_tag)
      strawberry_tag = create_taste_tag(name: "ストロベリー", parent: berry_tag)
      drink_log = build_drink_log(taste_tag: jasmine_tag)
      drink_log.drink_log_taste_tags.build(tag: strawberry_tag, position: 2)
      drink_log.save!

      expect(drink_log.aggregated_taste_tags).to contain_exactly(floral_tag, berry_tag)
    end
  end

  describe "#weighted_taste_tag_scores" do
    it "味わいタグを選択順に応じたスコアで返すこと" do
      floral_tag = create_taste_tag(name: "花")
      berry_tag = create_taste_tag(name: "ベリー")
      chocolate_tag = create_taste_tag(name: "チョコレート")
      drink_log = build_drink_log(taste_tag: floral_tag)
      drink_log.drink_log_taste_tags.build(tag: berry_tag, position: 2)
      drink_log.drink_log_taste_tags.build(tag: chocolate_tag, position: 3)
      drink_log.save!

      expect(drink_log.weighted_taste_tag_scores).to eq(
        floral_tag => 3,
        berry_tag => 2,
        chocolate_tag => 1
      )
    end

    it "小項目タグは親タグのスコアとして返すこと" do
      floral_tag = create_taste_tag(name: "花")
      jasmine_tag = create_taste_tag(name: "ジャスミン", parent: floral_tag)
      drink_log = create_drink_log(taste_tag: jasmine_tag)

      expect(drink_log.weighted_taste_tag_scores).to eq(floral_tag => 3)
    end

    it "同じ親を持つ小項目タグは1ログ内で最も高いスコアだけを返すこと" do
      floral_tag = create_taste_tag(name: "花")
      jasmine_tag = create_taste_tag(name: "ジャスミン", parent: floral_tag)
      chamomile_tag = create_taste_tag(name: "カモミール", parent: floral_tag)
      drink_log = build_drink_log(taste_tag: jasmine_tag)
      drink_log.drink_log_taste_tags.build(tag: chamomile_tag, position: 2)
      drink_log.save!

      expect(drink_log.weighted_taste_tag_scores).to eq(floral_tag => 3)
    end
  end

  describe "#ordered_taste_tags" do
    it "味わいタグをposition順に返すこと" do
      first_taste_tag = create_taste_tag(name: "ベリー")
      second_taste_tag = create_taste_tag(name: "チョコレート")
      drink_log = build_drink_log(taste_tag: second_taste_tag)
      drink_log.drink_log_taste_tags.build(tag: first_taste_tag, position: 2)
      drink_log.save!

      expect(drink_log.ordered_taste_tags).to eq([ second_taste_tag, first_taste_tag ])
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

    it "焙煎度タグに紐づくこと" do
      roast_level_tag = create_roast_level_tag
      drink_log = create_drink_log(roast_level_tag:)

      expect(drink_log.roast_level_tag).to eq(roast_level_tag)
    end

    it "複数の味わいタグに紐づけられること" do
      first_taste_tag = create_taste_tag(name: "フルーティー")
      second_taste_tag = create_taste_tag(name: "甘い")
      drink_log = build_drink_log(taste_tag: first_taste_tag)
      drink_log.drink_log_taste_tags.build(tag: second_taste_tag, position: 2)
      drink_log.save!

      expect(drink_log.taste_tags).to contain_exactly(first_taste_tag, second_taste_tag)
    end

    it "飲んだログ削除時に味わいタグ中間レコードも削除されること" do
      drink_log = create_drink_log

      expect { drink_log.destroy }.to change(DrinkLogTasteTag, :count).by(-1)
    end
  end
end
