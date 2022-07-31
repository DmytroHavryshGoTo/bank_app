require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:transaction) { create(:transaction, amount_cents: 100_00, amount_currency: 'USD') }

  describe '.formatted_amount' do
    it 'returns formatted amount' do
      expect(transaction.formatted_amount).to eq '$100.00'
    end
  end
end
