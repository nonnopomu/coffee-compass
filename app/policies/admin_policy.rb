class AdminPolicy < ApplicationPolicy
  def access?
    user.present? && user.admin?
  end
end
