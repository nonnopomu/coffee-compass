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

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "google-uid-123",
        info: {
          email: "google-user@example.com",
          name: "Googleユーザー"
        }
      )
    end

    it "Google認証情報からユーザーを作成できること" do
      expect {
        described_class.from_omniauth(auth)
      }.to change(described_class, :count).by(1)

      user = described_class.last

      expect(user.email).to eq("google-user@example.com")
      expect(user.name).to eq("Googleユーザー")
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("google-uid-123")
    end

    it "同じproviderとuidのユーザーが存在する場合は既存ユーザーを返すこと" do
      existing_user = create_user(email: "existing-google@example.com")
      existing_user.update!(provider: "google_oauth2", uid: "google-uid-123")

      expect {
        result = described_class.from_omniauth(auth)

        expect(result).to eq(existing_user)
      }.not_to change(described_class, :count)
    end

    it "同じメールアドレスの通常ユーザーが存在する場合はGoogle認証情報を紐づけること" do
      existing_user = create_user(email: "google-user@example.com")

      expect {
        result = described_class.from_omniauth(auth)

        expect(result).to eq(existing_user)
      }.not_to change(described_class, :count)

      existing_user.reload
      expect(existing_user.provider).to eq("google_oauth2")
      expect(existing_user.uid).to eq("google-uid-123")
    end

    it "Googleの名前がない場合はメールアドレスから名前を補完すること" do
      auth_without_name = Struct.new(:provider, :uid, :info).new(
        "google_oauth2",
        "google-uid-without-name",
        Struct.new(:email, :name).new("google-user@example.com", nil)
      )

      user = described_class.from_omniauth(auth_without_name)

      expect(user.name).to eq("google-user")
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
