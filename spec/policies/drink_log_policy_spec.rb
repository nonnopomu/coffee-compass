require "rails_helper"

RSpec.describe DrinkLogPolicy, type: :policy do
  let(:owner) { create_user }
  let(:other_user) { create_user }
  let(:admin) { create_user(role: :admin) }
  let(:drink_log) { create_drink_log(user: owner) }

  describe "ログ作成" do
    it "ログインユーザーは作成できること" do
      expect(described_class.new(owner, DrinkLog.new).create?).to be true
    end

    it "未ログインユーザーは作成できないこと" do
      expect(described_class.new(nil, DrinkLog.new).create?).to be false
    end
  end

  describe "ログ更新" do
    it "投稿者本人は更新できること" do
      expect(described_class.new(owner, drink_log).update?).to be true
    end

    it "管理者は更新できること" do
      expect(described_class.new(admin, drink_log).update?).to be true
    end

    it "投稿者以外の一般ユーザーは更新できないこと" do
      expect(described_class.new(other_user, drink_log).update?).to be false
    end
  end

  describe "ログ削除" do
    it "投稿者本人は削除できること" do
      expect(described_class.new(owner, drink_log).destroy?).to be true
    end

    it "管理者は削除できること" do
      expect(described_class.new(admin, drink_log).destroy?).to be true
    end

    it "投稿者以外の一般ユーザーは削除できないこと" do
      expect(described_class.new(other_user, drink_log).destroy?).to be false
    end
  end
end
