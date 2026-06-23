class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  enum :role, { general: 0, admin: 1 }

  has_many :drink_logs, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true, length: { maximum: 50 }

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    user ||= find_or_initialize_by(email: auth.info.email)

    user.provider = auth.provider
    user.uid = auth.uid
    user.name = auth.info.name.presence || auth.info.email.split("@").first
    user.password = Devise.friendly_token[0, 20] if user.new_record?

    user.save!
    user
  end
end
