require "rails_helper"

RSpec.describe TagPolicy, type: :policy do
  let(:tag) { Tag.new(name: "フルーティー", category: :taste, display_order: 1) }

  describe "管理者権限" do
    let(:admin) { build_user(role: :admin) }
    let(:policy) { described_class.new(admin, tag) }

    it "タグを作成できること" do
      expect(policy.create?).to be true
    end

    it "タグを更新できること" do
      expect(policy.update?).to be true
    end

    it "タグを削除できること" do
      expect(policy.destroy?).to be true
    end
  end

  describe "一般ユーザー権限" do
    let(:general_user) { build_user }
    let(:policy) { described_class.new(general_user, tag) }

    it "タグを作成できないこと" do
      expect(policy.create?).to be false
    end

    it "タグを更新できないこと" do
      expect(policy.update?).to be false
    end

    it "タグを削除できないこと" do
      expect(policy.destroy?).to be false
    end
  end
end
