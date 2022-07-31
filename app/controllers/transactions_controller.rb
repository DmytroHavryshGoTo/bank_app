class TransactionsController < AuthenticatedController
  before_action :set_transaction, only: %i[show confirm verify]

  def show; end

  def new
    @transaction = Transaction.new
  end

  def create
    create_service = Transactions::CreateService.call(transaction_params.to_h.symbolize_keys)
    return redirect_to new_transaction_path, alert: create_service.failure unless create_service.success?

    redirect_to transaction_path(create_service.value!)
  end

  def verify
    confirm_service = Transactions::VerifyService.call(user_id: current_user.id, transaction_id: @transaction.id,
                                                       code: params[:transaction_verify][:code])
    return redirect_to transaction_path(@transaction), alert: confirm_service.failure unless confirm_service.success?

    redirect_to root_path, alert: 'Transaction completed!'
  end

  def confirm
    confirm_service = Transactions::ConfirmService.call(user_id: current_user.id, transaction_id: @transaction.id)
    redirect_to new_transaction_path, alert: confirm_service.failure unless confirm_service.success?
  end

  private

  def set_transaction
    @transaction = current_user.transactions.where(status: %i[pending
                                                              created]).find(params[:id] || params[:transaction_id])
  end

  def transaction_params
    params.require(:transaction).permit(:from_account_id, :amount, :to_account_number)
  end
end
