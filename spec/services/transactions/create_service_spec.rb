require 'rails_helper'

RSpec.describe Transactions::CreateService, '#call' do
  subject { described_class.call(params) }

  let(:user1) { create(:user, :with_usd_account, :with_eur_account) }
  let(:user2) { create(:user, :with_usd_account, :with_eur_account) }
  let(:amount) { 100 }

  context 'valid flow' do
    context 'transaction from user1 USD account to user2 USD account' do
      let(:params) do
        {
          from_account_id: user1.accounts.find_by(balance_currency: 'USD').id,
          to_account_number: user2.accounts.find_by(balance_currency: 'USD').number,
          amount: amount
        }
      end

      it 'successfully creates transaction' do
        expect(subject.success?).to be_truthy
        expect(subject.value!).to be_a Transaction
        expect(subject.value!.from_account).to eq user1.accounts.find_by(balance_currency: 'USD')
        expect(subject.value!.to_account).to eq user2.accounts.find_by(balance_currency: 'USD')
        expect(subject.value!.amount_cents).to eq amount * 100
        expect(subject.value!.status).to eq 'created'
      end
    end

    context 'transaction from user1 USD account to user1 EUR account' do
      let(:params) do
        {
          from_account_id: user1.accounts.find_by(balance_currency: 'USD').id,
          to_account_number: user1.accounts.find_by(balance_currency: 'EUR').number,
          amount: 100
        }
      end

      it 'successfully creates transaction' do
        expect(subject.success?).to be_truthy
        expect(subject.value!).to be_a Transaction
        expect(subject.value!.from_account).to eq user1.accounts.find_by(balance_currency: 'USD')
        expect(subject.value!.to_account).to eq user1.accounts.find_by(balance_currency: 'EUR')
        expect(subject.value!.amount_cents).to eq amount * 100
        expect(subject.value!.status).to eq 'created'
      end
    end
  end

  context 'invalid flow' do
    context 'transaction from user1 USD account to user2 USD account with negative amount' do
      let(:params) do
        {
          from_account_id: user1.accounts.find_by(balance_currency: 'USD').id,
          to_account_number: user2.accounts.find_by(balance_currency: 'USD').number,
          amount: -amount
        }
      end

      it 'does not create transaction' do
        expect(subject.success?).to be_falsy
        expect { subject }.not_to change { Transaction.count }
      end
    end

    context 'transaction from user1 USD account to user1 USD account' do
      let(:params) do
        {
          from_account_id: user1.accounts.find_by(balance_currency: 'USD').id,
          to_account_number: user1.accounts.find_by(balance_currency: 'USD').number,
          amount: 100
        }
      end

      it 'does not create transaction' do
        expect(subject.success?).to be_falsy
        expect { subject }.not_to change { Transaction.count }
      end
    end
  end
end
