class Account < ApplicationRecord
  has_secure_password

  has_many :roles, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :punishments, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :past_usernames, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :balance, numericality: true
  validates :status, presence: true

  def active_membership
    memberships.where("expires_at > ?", Time.current).order(expires_at: :desc).first
  end

  def is_account_verified
    self.verified || false
  end
end
