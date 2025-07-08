class Friend < ApplicationRecord
  belongs_to :sent_by, class_name: "Account"
  belongs_to :sent_to, class_name: "Account"

  validates :status, presence: true, inclusion: { in: %w[pending friend follower] }
end
