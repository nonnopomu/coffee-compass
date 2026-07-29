require "rails_helper"

RSpec.describe AdminPolicy, type: :policy do
  describe "#access?" do
    it "管理者は管理画面へアクセスできること" do
      admin = build_user(role: :admin)
      policy = described_class.new(admin, :admin)

      expect(policy.access?).to be true
    end

    it "一般ユーザーは管理画面へアクセスできないこと" do
      user = build_user
      policy = described_class.new(user, :admin)

      expect(policy.access?).to be false
    end

    it "未ログインユーザーは管理画面へアクセスできないこと" do
      policy = described_class.new(nil, :admin)

      expect(policy.access?).to be false
    end
  end
end
