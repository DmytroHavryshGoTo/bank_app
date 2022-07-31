Rails.application.routes.draw do
  root 'accounts#index'

  devise_for :users

  resources :accounts, only: %i[index create new show]
  resources :transactions, only: %i[create new show] do
    post :verify
    post :confirm
  end
end
