class Membership < ApplicationRecord
  belongs_to :account

  validates :expires_at, presence: true
  validates :type, presence: true, numericality: { only_integer: true }
end
