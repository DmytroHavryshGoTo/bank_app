module Confirmations
  class RedisStorage
    def initialize
      @storage = Redis.new
    end

    def save_code(user_id, transaction_id, code)
      @storage.set("#{user_id}_#{transaction_id}_code", code, ex: 2.minutes)
    end

    def get_code(user_id, transaction_id)
      @storage.get("#{user_id}_#{transaction_id}_code")
    end
  end
end
