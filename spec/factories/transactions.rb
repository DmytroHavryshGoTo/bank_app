FactoryBot.define do
  factory :transaction do
    amount_currency { 'USD' }
    amount_cents { 100_00 }
    status { :created }
    from_account factory: :account
    to_account factory: :account
  end
end
