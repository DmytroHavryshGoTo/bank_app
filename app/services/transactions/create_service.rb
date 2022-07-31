module Transactions
  class CreateService < BaseService
    option :from_account_id
    option :to_account_number
    option :amount

    Schema = Dry::Schema.Params do
      required(:from_account_id).value(%i[string integer])
      required(:to_account_number).value(:string)
      required(:amount).value(:integer)
    end

    permissible_errors [ActiveRecord::RecordNotFound]

    def call
      return Failure.new('Account number not found') if to_account.blank?

      transaction = Transaction.new(
        from_account: from_account,
        to_account: to_account,
        amount: cents_amount
      )

      if transaction.save
        Success.new(transaction)
      else
        Failure.new(transaction.errors.full_messages.to_sentence)
      end
    end

    private

    def cents_amount
      Money.new(amount.to_i * 100, from_account.balance_currency)
    end

    def from_account
      @from_account ||= Account.find(from_account_id)
    end

    def to_account
      @to_account ||= Account.where.not(id: from_account_id).find_by(number: to_account_number.remove(' '))
    end
  end
end
