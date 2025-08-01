class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    @accounts = Account.all.order(:name)
    @total_balance = @accounts.sum(:balance)
  end

  def show
    @transactions = @account.transactions.recent.limit(20)
    @recent_income = @account.transactions.by_type('income').recent.limit(5)
    @recent_expenses = @account.transactions.by_type('expense').recent.limit(5)
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to @account, notice: 'Account was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: 'Account was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @account.transactions.exists?
      redirect_to accounts_path, alert: 'Cannot delete account with existing transactions.'
    else
      @account.destroy
      redirect_to accounts_path, notice: 'Account was successfully deleted.'
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :account_type, :balance, :description)
  end
end
