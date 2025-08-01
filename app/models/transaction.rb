class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :employee, optional: true
  
  # Transaction types enum
  enum :transaction_type, {
    income: 'income',
    expense: 'expense',
    loan: 'loan',
    transfer_in: 'transfer_in',
    transfer_out: 'transfer_out'
  }
  
  # Categories for different transaction types
  INCOME_CATEGORIES = [
    'salary', 'bonus', 'commission', 'investment_income', 'rental_income',
    'consulting', 'freelance', 'other_income'
  ].freeze
  
  EXPENSE_CATEGORIES = [
    'salary_expense', 'rent', 'utilities', 'office_supplies', 'equipment',
    'marketing', 'travel', 'meals', 'insurance', 'maintenance', 'other_expense'
  ].freeze
  
  LOAN_CATEGORIES = [
    'personal_loan', 'business_loan', 'mortgage', 'car_loan', 'student_loan',
    'credit_card_payment', 'other_loan'
  ].freeze
  
  TRANSFER_CATEGORIES = [
    'bank_transfer', 'cash_transfer', 'investment_transfer', 'loan_payment',
    'savings_transfer', 'other_transfer'
  ].freeze
  
  # Validations
  validates :account, presence: true
  validates :transaction_type, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_date, presence: true
  validates :category, presence: true
  validates :employee, presence: true, if: :loan?
  
  # Scopes
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_date_range, ->(start_date, end_date) { where(transaction_date: start_date..end_date) }
  scope :recent, -> { order(transaction_date: :desc, created_at: :desc) }
  scope :this_month, -> { where(transaction_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :this_year, -> { where(transaction_date: Date.current.beginning_of_year..Date.current.end_of_year) }
  scope :with_employee, -> { includes(:employee) }
  
  # Callbacks
  after_create :update_account_balance
  after_update :update_account_balance
  after_destroy :update_account_balance
  
  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount)
  end
  
  def income?
    transaction_type == 'income'
  end
  
  def expense?
    transaction_type == 'expense'
  end
  
  def loan?
    transaction_type == 'loan'
  end
  
  def transfer?
    transaction_type.in?(['transfer_in', 'transfer_out'])
  end
  
  def transfer_in?
    transaction_type == 'transfer_in'
  end
  
  def transfer_out?
    transaction_type == 'transfer_out'
  end
  
  def employee_name
    employee&.full_name || 'N/A'
  end
  
  def self.categories_for_type(transaction_type)
    case transaction_type
    when 'income'
      INCOME_CATEGORIES
    when 'expense'
      EXPENSE_CATEGORIES
    when 'loan'
      LOAN_CATEGORIES
    when 'transfer_in', 'transfer_out'
      TRANSFER_CATEGORIES
    else
      []
    end
  end
  
  def self.total_by_type_and_period(transaction_type, start_date = nil, end_date = nil)
    scope = by_type(transaction_type)
    scope = scope.by_date_range(start_date, end_date) if start_date && end_date
    scope.sum(:amount)
  end
  
  private
  
  def update_account_balance
    return unless account.present?
    
    # Calculate the new balance based on all transactions for this account
    new_balance = account.transactions.sum do |t|
      case t.transaction_type
      when 'income', 'transfer_in'
        t.amount
      when 'expense', 'loan', 'transfer_out'
        -t.amount
      else
        0
      end
    end
    
    # Update the account balance without triggering validations
    account.update_column(:balance, new_balance)
  end
end
