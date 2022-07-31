require 'rails_helper'

RSpec.describe Transactions::VerifyService, '#call' do
  subject { described_class.call(params) }

  let(:base_params) { { confirmation_storage: storage } }
  let(:params) { base_params.merge(case_params) }
  let(:user1) { create(:user, :with_usd_account) }
  let(:user2) { create(:user, :with_usd_account) }
  let(:user1_usd_balance) { user1.accounts.first }
  let(:user2_usd_balance) { user2.accounts.find_by(balance_currency: 'USD') }
  let(:transaction) do
    create(:transaction, from_account: user1_usd_balance, to_account: user2.accounts.first, status: :pending)
  end
  let(:confirmed_transaction) do
    create(:transaction, from_account: user2_usd_balance, to_account: user2.accounts.first, status: :confirmed)
  end
  let(:storage) { double('storage') }
  let(:code) { '1111' }

  before { expect(storage).to receive(:get_code).with(user1.id, transaction.id).and_return(code) }

  context 'valid flow' do
    let(:case_params) do
      {
        code: code,
        user_id: user1.id,
        transaction_id: transaction.id
      }
    end

    it 'successfully verifies transaction' do
      expect { subject }.to change { transaction.reload.status }.from('pending').to('confirmed')
      expect(subject.success?).to be_truthy
    end

    it 'successfully withdraw money from user1' do
      previous_user1_balance = user1_usd_balance.balance
      expect { subject }.to change {
                              user1_usd_balance.reload.balance
                            }.from(previous_user1_balance).to(previous_user1_balance - transaction.amount)
    end

    it 'successfully adds money to user2' do
      previous_user2_balance = user2_usd_balance.balance
      expect { subject }.to change {
                              user2_usd_balance.reload.balance
                            }.from(previous_user2_balance).to(previous_user2_balance + transaction.amount)
    end
  end

  context 'invalid flow' do
    context 'wrong code' do
      let(:case_params) do
        {
          code: '0000',
          user_id: user1.id,
          transaction_id: transaction.id
        }
      end

      it 'change transaction status to aborted' do
        expect { subject }.to change { transaction.reload.status }.from('pending').to('aborted')
        expect(subject.success?).to be_falsy
      end

      it 'does not change user1 balance' do
        expect { subject }.not_to change { user1_usd_balance.reload.balance }
      end

      it 'does not change user2 balance' do
        expect { subject }.not_to change { user2_usd_balance.reload.balance }
      end
    end

    context 'one of DB transactions is interrupted' do
      let(:case_params) do
        {
          code: code,
          user_id: user1.id,
          transaction_id: transaction.id
        }
      end

      before do
        expect_any_instance_of(Account).to receive(:save!).and_raise(ActiveRecord::ConnectionTimeoutError)
      end

      it 'change transaction status to aborted' do
        expect { subject }.to change { transaction.reload.status }.from('pending').to('aborted')
        expect(subject.success?).to be_falsy
      end

      it 'does not change user1 balance' do
        expect { subject }.not_to change { user1_usd_balance.reload.balance }
      end

      it 'does not change user2 balance' do
        expect { subject }.not_to change { user2_usd_balance.reload.balance }
      end
    end

    context 'user1 balance < transaction amount' do
      let(:case_params) do
        {
          code: code,
          user_id: user1.id,
          transaction_id: transaction.id
        }
      end

      before { user1_usd_balance.update(balance: Money.new(1, 'USD')) }

      it 'change transaction status to aborted' do
        expect { subject }.to change { transaction.reload.status }.from('pending').to('aborted')
        expect(subject.success?).to be_falsy
      end

      it 'does not change user1 balance' do
        expect { subject }.not_to change { user1_usd_balance.reload.balance }
      end

      it 'does not change user2 balance' do
        expect { subject }.not_to change { user2_usd_balance.reload.balance }
      end
    end
  end
end
