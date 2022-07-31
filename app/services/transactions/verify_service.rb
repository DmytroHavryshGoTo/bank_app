module Transactions
  class VerifyService < BaseService
    option :code
    option :user_id
    option :transaction_id
    option :confirmation_storage, default: -> { default_storage }

    Schema = Dry::Schema.Params do
      required(:code).value(:string)
      required(:user_id).value(:integer)
      required(:transaction_id).value(:integer)
    end

    permissible_errors [ActiveRecord::ActiveRecordError]

    def call
      unless confirmation_storage.get_code(user_id, transaction.id) == code
        abort_transaction!
        return Failure.new('Code in not valid or has been expired')
      end

      ActiveRecord::Base.transaction do
        from_account.balance -= transaction.amount
        to_account.balance += transaction.amount
        from_account.save!
        to_account.save!
        transaction.update!(status: :confirmed)
      end

      Success.new(transaction)
    rescue ActiveRecord::RecordNotFound => e
      raise e
    rescue ActiveRecord::ActiveRecordError => e
      abort_transaction!
      raise e
    end

    private

    def abort_transaction!
      transaction.aborted!
    end

    def default_storage
      ::Confirmations::RedisStorage.new
    end

    def user
      @user ||= User.find(user_id)
    end

    def from_account
      @from_account ||= transaction.from_account
    end

    def to_account
      @to_account ||= transaction.to_account
    end

    def transaction
      @transaction ||= Transaction.where(from_account_id: user.accounts.select(:id)).pending.find(transaction_id)
    end
  end
end
