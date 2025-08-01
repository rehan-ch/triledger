class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :set_accounts, only: [:new, :create, :edit, :update]
  before_action :set_employees, only: [:new, :create, :edit, :update]

  def index
    @transactions = Transaction.includes(:account, :employee).recent
    
    # Apply filters
    @transactions = @transactions.by_type(params[:transaction_type]) if params[:transaction_type].present?
    @transactions = @transactions.where(account_id: params[:account_id]) if params[:account_id].present?
    
    if params[:start_date].present? && params[:end_date].present?
      @transactions = @transactions.by_date_range(params[:start_date], params[:end_date])
    end
    
    @total_income = Transaction.total_by_type_and_period('income')
    @total_expenses = Transaction.total_by_type_and_period('expense')
    @total_loans = Transaction.total_by_type_and_period('loan')
    @net_balance = @total_income - @total_expenses - @total_loans
  end

  def show
  end

  def new
    @transaction = Transaction.new(transaction_date: Date.current)
    @transaction.account_id = params[:account_id] if params[:account_id].present?
  end

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      redirect_to @transaction, notice: 'Transaction was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: 'Transaction was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_path, notice: 'Transaction was successfully deleted.'
  end

  def categories
    transaction_type = params[:transaction_type]
    categories = Transaction.categories_for_type(transaction_type)
    render json: { categories: categories }
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def set_accounts
    @accounts = Account.all.order(:name)
  end

  def set_employees
    @employees = Employee.includes(:user).active.order('users.first_name, users.last_name')
  end

  def transaction_params
    params.require(:transaction).permit(:account_id, :transaction_type, :amount, 
                                      :description, :reference, :transaction_date, :category, :employee_id)
  end
end
