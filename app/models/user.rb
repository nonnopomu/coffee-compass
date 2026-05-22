class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { general: 0, admin: 1 }

  has_many :drink_logs, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
end
