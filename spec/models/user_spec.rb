require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "有効な属性で作成できること" do
      expect(build_user).to be_valid
    end

    it "メールアドレスが必須であること" do
      user = build_user(email: "")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "メールアドレスが一意であること" do
      existing_user = create_user(email: "duplicate@example.com")
      user = build_user(email: existing_user.email)

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "パスワードが必須であること" do
      user = build_user(password: "", password_confirmation: "")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "名前が必須であること" do
      user = build_user(name: "")

      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "名前が50文字以内であること" do
      user = build_user(name: "a" * 51)

      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end
  end

  describe "ロール" do
    it "初期値がgeneralであること" do
      expect(described_class.new).to be_general
    end

    it "adminに変更できること" do
      user = create_user

      user.admin!

      expect(user).to be_admin
    end
  end

  describe "関連付け" do
    it "ユーザー削除時に紐づく飲んだログも削除されること" do
      user = create_user
      create_drink_log(user:)

      expect { user.destroy }.to change(DrinkLog, :count).by(-1)
    end
  end
end
