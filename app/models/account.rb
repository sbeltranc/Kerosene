class Account < ApplicationRecord
  has_secure_password

  has_many :roles, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :punishments, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :past_usernames, dependent: :destroy
  has_many :two_step_verification_tickets, dependent: :destroy

  has_many :sent_friend_requests, class_name: "Friend", foreign_key: :sent_by_id, dependent: :destroy
  has_many :received_friend_requests, class_name: "Friend", foreign_key: :sent_to_id, dependent: :destroy

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

  def is_account_banned
    punishment = self.punishments.where(confirmed: false).order(created_at: :desc).first

    if punishment
      punishment.expires_at && punishment.expires_at > Time.current
    end

    false
  end

  def is_account_allowed
    if self.is_account_verified
      render json: respond_with_error(0, "User must verify their email before doing this action."), status: :forbidden
      false
    end

    if self.is_account_banned
      render json: respond_with_error(0, "User is banned."), status: :forbidden
      false
    end

    true
  end
end
