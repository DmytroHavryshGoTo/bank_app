require 'rails_helper'

RSpec.describe AccountsController do
  let(:user) { create(:user, :with_usd_account) }

  describe 'new' do
    subject { get :new }

    context 'success' do
      before do
        sign_in_user(user)
      end
      it 'renders new_account page' do
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
    subject { get :show, params: params }
    let(:params) { { id: user.accounts.first.id } }

    context 'success' do
      before do
        sign_in_user(user)
      end
      it 'renders show page' do
        expect(subject).to render_template(:show)
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
    let(:params) do
      {
        account: {
          balance_currency: 'EUR'
        }
      }
    end

    context 'success' do
      before do
        sign_in_user(user)
      end

      it 'renders accounts page' do
        expect(subject).to redirect_to "/accounts/#{assigns(:account).id}"
      end
    end

    context 'error' do
      before do
        sign_in_user(user)
      end

      let(:params) do
        {
          account: {
            balance_currency: 'USD'
          }
        }
      end

      it 'renders accounts page' do
        expect(subject).to render_template(:new)
      end
    end

    context 'unauthorized' do
      it 'redirects to login page' do
        expect(subject).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'create' do
    subject { get :index }

    context 'success' do
      before do
        sign_in_user(user)
      end

      it 'renders accounts page' do
        expect(subject).to render_template(:index)
        expect(assigns(:accounts)).to match_array(user.accounts)
      end
    end

    context 'unauthorized' do
      it 'redirects to login page' do
        expect(subject).to redirect_to '/users/sign_in'
      end
    end
  end
end
