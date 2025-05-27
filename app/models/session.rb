class Session < ApplicationRecord
  belongs_to :account
  validates :token, presence: true, uniqueness: true
end
