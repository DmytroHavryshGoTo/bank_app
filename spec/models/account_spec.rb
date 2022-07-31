require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:account) { create(:account, balance_currency: 'USD', balance_cents: 100_00, number: '2585659085454918') }

  describe '.transactions' do
    let!(:from_transactions) { create_list(:transaction, 2, status: :confirmed, from_account: account) }
    let!(:to_transactions) { create_list(:transaction, 2, status: :confirmed, to_account: account) }
    let!(:pending_transactions) { create_list(:transaction, 2, status: :pending, to_account: account) }
    let!(:other_transactions) { create_list(:transaction, 2) }

    it 'returns only related confirmed transactions' do
      expect(account.transactions).to match_array(from_transactions + to_transactions)
    end
  end

  describe '.formatted_name' do
    it 'correctly display balance name' do
      expect(account.formatted_name).to eq '2585 6590 8545 4918 USD'
    end
  end

  describe '.hidden_number' do
    it 'correctly display card number' do
      expect(account.hidden_number).to eq 'XXXX-XXXX-XXXX-4918'
    end
  end

  describe '.formatted_balance' do
    it 'correctly display balance in currency format' do
      expect(account.formatted_balance).to eq '$100.00'
    end
  end

  describe '.formatted_number' do
    it 'correctly display formatted number' do
      expect(account.formatted_number).to eq '2585 6590 8545 4918'
    end
  end

  describe '.add_money' do
    it 'adds money to balance' do
      prev_balance = account.balance
      expect { account.add_money(100) }.to change {
                                             account.reload.balance
                                           }.from(prev_balance).to(prev_balance + Money.new(100_00,
                                                                                            account.balance_currency))
    end
  end
end
