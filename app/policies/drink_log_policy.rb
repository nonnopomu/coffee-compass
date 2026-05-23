class DrinkLogPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    record.user == user || user.admin?
  end

  def destroy?
    record.user == user || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
  end
end
