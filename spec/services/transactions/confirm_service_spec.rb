require 'rails_helper'

RSpec.describe Transactions::ConfirmService, '#call' do
  subject { described_class.call(params) }

  let(:base_params) { { confirmation_sender_client: sender, confirmation_storage: storage } }
  let(:params) { base_params.merge(case_params) }
  let(:user1) { create(:user, :with_usd_account) }
  let(:user2) { create(:user, :with_usd_account) }
  let(:transaction) { create(:transaction, from_account: user1.accounts.first, to_account: user2.accounts.first) }
  let(:pending_transaction) do
    create(:transaction, from_account: user1.accounts.first, to_account: user2.accounts.first, status: :pending)
  end
  let(:sender) { double('sender') }
  let(:storage) { double('storage') }
  let(:code) { '1111' }

  context 'valid flow' do
    let(:case_params) do
      {
        user_id: user1.id,
        transaction_id: transaction.id
      }
    end

    it 'successfully creates transaction' do
      expect(sender).to receive(:send_code).with(user1.id, anything)
      expect(storage).to receive(:save_code).with(user1.id, transaction.id, anything)

      expect { subject }.to change { transaction.reload.status }.from('created').to('pending')
      expect(subject.success?).to be_truthy
    end
  end

  context 'invalid flow' do
    let(:case_params) do
      {
        user_id: user1.id,
        transaction_id: pending_transaction.id
      }
    end

    context 'wrong user' do
      it 'does not confirm transaction' do
        expect(subject.success?).to be_falsy
        expect(transaction.status).to eq 'created'
      end
    end

    context 'transaction status is invalid' do
      it 'successfully creates transaction' do
        expect(subject.success?).to be_falsy
      end
    end
  end
end
