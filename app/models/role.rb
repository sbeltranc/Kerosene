class Role < ApplicationRecord
  belongs_to :account
  validates :role, presence: true
end
