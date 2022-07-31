class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  validates :first_name, :last_name, presence: true

  has_many :accounts, dependent: :nullify

  def transactions
    Transaction.where(from_account_id: accounts.select(:id)).or(Transaction.where(to_account_id: accounts.select(:id)))
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def sms_notifications
    Redis.new.lrange("#{id}_sms_codes", 0, -1).to_a
  end
end
