class TwoStepVerificationTicket < ApplicationRecord
  belongs_to :account

  validates :ticket, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :set_defaults, on: :create

  scope :valid, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def valid?
    expires_at > Time.current
  end

  private

  def set_defaults
    self.ticket ||= SecureRandom.hex(32)
    self.expires_at ||= 10.minutes.from_now
  end
end 