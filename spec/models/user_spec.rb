require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user, first_name: 'John', last_name: 'Dou') }

  describe '.transactions' do
    let(:account) { create(:account, user: user) }
    let!(:from_transactions) { create_list(:transaction, 2, from_account: account) }
    let!(:to_transactions) { create_list(:transaction, 2, to_account: account) }
    let!(:other_transactions) { create_list(:transaction, 2) }

    it 'returns only user transactions' do
      expect(user.transactions).to match_array(from_transactions + to_transactions)
    end
  end

  describe '.full_name' do
    it 'returns user full name' do
      expect(user.full_name).to eq 'John Dou'
    end
  end

  describe '.sms_notifications' do
    it 'returns mocked sms notifications' do
      codes = %w[1234 5678]
      expect_any_instance_of(Redis).to receive(:lrange).and_return(codes)
      expect(user.sms_notifications).to eq codes
    end
  end
end
