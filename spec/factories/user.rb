FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :with_usd_account do
      after(:create) do |user, _evaluator|
        create(:account, user: user, balance_currency: 'USD', balance_cents: 100_000_00)
      end
    end

    trait :with_eur_account do
      after(:create) do |user, _evaluator|
        create(:account, user: user, balance_currency: 'EUR', balance_cents: 100_000_00)
      end
    end
  end
end
