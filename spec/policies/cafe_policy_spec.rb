require "rails_helper"

RSpec.describe CafePolicy, type: :policy do
  let(:cafe) { build_cafe }

  describe "管理者権限" do
    let(:admin) { build_user(role: :admin) }
    let(:policy) { described_class.new(admin, cafe) }

    it "カフェを作成できること" do
      expect(policy.create?).to be true
    end

    it "カフェを更新できること" do
      expect(policy.update?).to be true
    end

    it "カフェを削除できること" do
      expect(policy.destroy?).to be true
    end
  end

  describe "一般ユーザー権限" do
    let(:general_user) { build_user }
    let(:policy) { described_class.new(general_user, cafe) }

    it "カフェを作成できないこと" do
      expect(policy.create?).to be false
    end

    it "カフェを更新できないこと" do
      expect(policy.update?).to be false
    end

    it "カフェを削除できないこと" do
      expect(policy.destroy?).to be false
    end
  end
end
