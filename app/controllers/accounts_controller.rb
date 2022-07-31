class AccountsController < AuthenticatedController
  before_action :set_account, only: %i[show]

  def index
    @accounts = current_user.accounts
  end

  def show; end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params.merge({ user_id: current_user.id, balance_cents: 0.00 }))

    if @account.save
      redirect_to account_url(@account), notice: 'Account was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:balance_currency)
  end
end
