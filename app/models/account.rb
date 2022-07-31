class Account < ApplicationRecord
  belongs_to :user

  validates :balance_currency, inclusion: { in: SUPPORTED_CURRENCIES,
                                            message: '%<value>s is not a valid currency' }
  validates :balance_currency, uniqueness: { scope: %i[user_id],
                                             message: 'you already have account in %<value>s' }
  validates :number, uniqueness: true
  validates :balance_cents, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_number, on: :create

  monetize :balance_cents

  def transactions
    Transaction.where(from_account_id: id).or(Transaction.where(to_account_id: id)).confirmed.order(created_at: :desc)
  end

  def formatted_name
    "#{formatted_number} #{balance_currency}"
  end

  def hidden_number
    "XXXX-XXXX-XXXX-#{number[-4..]}"
  end

  def formatted_balance
    balance.format
  end

  def formatted_number
    number.gsub(/(.{4})(?=.)/, '\1 \2')
  end

  def add_money(amount = 100)
    self.balance += Money.new(amount * 100, balance_currency)
    save
  end

  private

  def set_number
    self.number ||= Faker::Bank.account_number(digits: 16)
  end
end
