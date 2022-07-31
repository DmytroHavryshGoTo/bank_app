FactoryBot.define do
  factory :account do
    balance_currency { 'USD' }
    balance_cents { 100_000_00 }
    user
  end
end
