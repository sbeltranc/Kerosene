class Account < ApplicationRecord
  has_secure_password

  has_many :roles, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :past_usernames, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :balance, numericality: true
  validates :status, presence: true
end
