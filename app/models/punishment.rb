class Punishment < ApplicationRecord
  belongs_to :account

  validates :simuldev_id, presence: true
  validates :reason, presence: true
  validates :punishment_type, presence: true, numericality: { only_integer: true }
  validates :confirmed, inclusion: { in: [ true, false ] }
end
