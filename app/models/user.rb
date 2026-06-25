class User < ApplicationRecord
  include ImageAttachmentValidatable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  enum :role, { general: 0, admin: 1 }

  has_many :drink_logs, dependent: :destroy
  has_one_attached :avatar

  validates_image_attachment :avatar

  validates :name, presence: true, length: { maximum: 50 }
  validate :email_cannot_be_changed_for_google_oauth_user, if: -> { persisted? && will_save_change_to_email? }

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    user ||= find_or_initialize_by(email: auth.info.email)

    user.provider = auth.provider
    user.uid = auth.uid
    user.name = auth.info.name.presence || auth.info.email.split("@").first if user.name.blank?
    user.password = Devise.friendly_token[0, 20] if user.new_record?

    user.save!
    user
  end

  def google_oauth_user?
    provider == "google_oauth2" && uid.present?
  end

  private

  def email_cannot_be_changed_for_google_oauth_user
    return unless google_oauth_user?

    errors.add(:email, :google_oauth_user_email_change_restricted)
  end
end
