class PastUsername < ApplicationRecord
  belongs_to :account
  validates :username, presence: true
end
