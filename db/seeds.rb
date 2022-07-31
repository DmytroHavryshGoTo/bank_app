(1..2).each do |i|
  user = User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: "user#{i}@example.com",
                     password: '123456')
  user.accounts.create(balance_cents: 100_000_00, balance_currency: 'USD')
  user.accounts.create(balance_cents: 100_000_00, balance_currency: 'EUR')
end
