namespace :users do
  desc 'add 100_000 to each of users'
  task add_money: :environment do
    Account.find_each do |account|
      account.balance += Money.new(100_000_00, account.balance_currency)
      account.save
    end
  end
end
