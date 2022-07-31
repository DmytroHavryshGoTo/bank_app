module Transactions
  class ConfirmService < BaseService
    option :user_id
    option :transaction_id
    option :confirmation_sender_client, default: -> { default_sender_client }
    option :confirmation_storage, default: -> { default_storage }

    Schema = Dry::Schema.Params do
      required(:user_id).value(:integer)
      required(:transaction_id).value(:integer)
    end

    permissible_errors [ActiveRecord::RecordNotFound]

    def call
      transaction.pending!
      code = Faker::Number.number(digits: 4).to_s
      confirmation_storage.save_code(user_id, transaction_id, code)
      confirmation_sender_client.send_code(user_id, code)

      Success.new(transaction)
    end

    private

    def default_storage
      ::Confirmations::RedisStorage.new
    end

    def default_sender_client
      ::Confirmations::RedisSenderClient.new
    end

    def user
      @user ||= User.find(user_id)
    end

    def transaction
      @transaction ||= Transaction.where(from_account_id: user.accounts.select(:id)).created.find(transaction_id)
    end
  end
end
