class Transaction < ApplicationRecord
  belongs_to :from_account, foreign_key: 'from_account_id', class_name: 'Account'
  belongs_to :to_account, foreign_key: 'to_account_id', class_name: 'Account'

  validates :amount_cents, numericality: { greater_than_or_equal_to: 100 }

  monetize :amount_cents

  enum status: {
    created: 0,
    pending: 1,
    confirmed: 2,
    aborted: 3
  }

  def formatted_amount
    amount.format
  end
end
