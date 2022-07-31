require 'rails_helper'

RSpec.describe TransactionsController do
  let(:user) { create(:user) }
  describe 'new' do
    subject { get :new }

    context 'success' do
      before do
        sign_in_user(user)
      end
      it 'renders new_transaction page' do
        expect(subject).to render_template(:new)
      end
    end

    context 'unauthorized' do
      it 'redirects to login page' do
        expect(subject).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'show' do
    subject { get :show, params: { id: transaction.id } }
    let(:account) { create(:account, user: user) }
    let(:transaction) { create(:transaction, from_account: account) }

    context 'success' do
      before do
        sign_in_user(user)
      end
      it 'renders show page' do
        expect(subject).to render_template(:show)
        expect(assigns(:transaction)).to eq transaction
      end
    end

    context 'unauthorized' do
      it 'redirects to login page' do
        expect(subject).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'create' do
    subject { post :create, params: params }
    let(:user1_with_usd_account) { create(:user, :with_usd_account) }
    let(:user2_with_usd_account) { create(:user, :with_usd_account) }
    let(:params) do
      {
        transaction: {
          from_account_id: user1_with_usd_account.accounts.first.id,
          to_account_number: user2_with_usd_account.accounts.first.number,
          amount: 100
        }
      }
    end

    context 'success' do
      before do
        sign_in_user(user1_with_usd_account)
      end
      it 'renders show page' do
        expect(Transactions::CreateService).to receive(:call).with(
          { from_account_id: user1_with_usd_account.accounts.first.id.to_s,
            to_account_number: user2_with_usd_account.accounts.first.number,
            amount: '100' }
        ).and_return(OpenStruct.new({ success?: true,
                                      value!: 1 }))
        expect(subject).to redirect_to '/transactions/1'
      end
    end

    context 'error' do
      before do
        sign_in_user(user1_with_usd_account)
      end
      it 'renders show page' do
        expect(Transactions::CreateService).to receive(:call).with(
          { from_account_id: user1_with_usd_account.accounts.first.id.to_s,
            to_account_number: user2_with_usd_account.accounts.first.number,
            amount: '100' }
        ).and_return(OpenStruct.new({
                                      success?: false, failure: 'error'
                                    }))
        expect(subject).to redirect_to '/transactions/new'
      end
    end

    context 'unauthorized' do
      it 'redirects to login page' do
        expect(subject).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'confirm' do
    subject { post :confirm, params: params }
    let(:user1_with_usd_account) { create(:user, :with_usd_account) }
    let(:params) { { transaction_id: transaction.id } }
    let(:transaction) { create(:transaction, from_account: user1_with_usd_account.accounts.first) }

    context 'success' do
      before do
        sign_in_user(user1_with_usd_account)
      end
      it 'renders confirm page' do
        expect(Transactions::ConfirmService).to receive(:call).with(
          { user_id: user1_with_usd_account.id,
            transaction_id: transaction.id }
        ).and_return(OpenStruct.new({ success?: true }))
        expect(subject).to render_template(:confirm)
      end
    end

    context 'error' do
      before do
        sign_in_user(user1_with_usd_account)
      end
      it 'renders show page' do
        expect(Transactions::ConfirmService).to receive(:call).with(
          { user_id: user1_with_usd_account.id,
            transaction_id: transaction.id }
        ).and_return(OpenStruct.new({
                                      success?: false, failure: 'error'
                                    }))

        expect(subject).to redirect_to '/transactions/new'
      end
    end

    context 'unauthorized' do
      it 'redirects to login page' do
        expect(subject).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'verify' do
    subject { post :verify, params: params }
    let(:user1_with_usd_account) { create(:user, :with_usd_account) }
    let(:params) { { transaction_id: transaction.id, transaction_verify: { code: '1111' } } }
    let(:transaction) { create(:transaction, status: :pending, from_account: user1_with_usd_account.accounts.first) }

    context 'success' do
      before do
        sign_in_user(user1_with_usd_account)
      end
      it 'renders confirm page' do
        expect(Transactions::VerifyService).to receive(:call).with(
          { user_id: user1_with_usd_account.id,
            transaction_id: transaction.id, code: '1111' }
        ).and_return(OpenStruct.new({ success?: true }))
        expect(subject).to redirect_to '/'
      end
    end

    context '302' do
      before do
        sign_in_user(user1_with_usd_account)
      end
      it 'renders show page' do
        expect(Transactions::VerifyService).to receive(:call).with(
          { user_id: user1_with_usd_account.id,
            transaction_id: transaction.id, code: '1111' }
        ).and_return(OpenStruct.new({
                                      success?: false, failure: 'error'
                                    }))

        expect(subject).to redirect_to "/transactions/#{transaction.id}"
      end
    end

    context '401' do
      it 'redirects to login page' do
        expect(subject).to redirect_to '/users/sign_in'
      end
    end
  end
end
