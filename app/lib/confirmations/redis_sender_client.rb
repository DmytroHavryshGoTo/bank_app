module Confirmations
  # This class emulates sendign SMS to users, instead of sending it just saves code in Redis
  #
  class RedisSenderClient
    def initialize
      @storage = Redis.new
    end

    def send_code(user_id, code)
      @storage.lpush("#{user_id}_sms_codes", code)
    end
  end
end
