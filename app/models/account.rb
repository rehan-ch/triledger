class Account < ApplicationRecord
  has_many :transactions, dependent: :destroy
  
  # Account types enum
  enum :account_type, {
    cash: 'cash',
    bank: 'bank',
    credit_card: 'credit_card',
    investment: 'investment',
    loan: 'loan',
    savings: 'savings',
    petty_cash: 'petty_cash'
  }
  
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :account_type, presence: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }, unless: :allows_negative_balance?
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(account_type: type) }
  scope :with_balance, -> { where('balance > 0') }
  
  # Callbacks
  before_create :set_default_balance
  
  def display_name
    "#{name} (#{account_type.humanize})"
  end
  
  def formatted_balance
    ActionController::Base.helpers.number_to_currency(balance)
  end
  
  def total_income
    transactions.where(transaction_type: 'income').sum(:amount)
  end
  
  def total_expenses
    transactions.where(transaction_type: 'expense').sum(:amount)
  end
  
  def total_loans
    transactions.where(transaction_type: 'loan').sum(:amount)
  end
  
  def total_transfers_in
    transactions.where(transaction_type: 'transfer_in').sum(:amount)
  end
  
  def total_transfers_out
    transactions.where(transaction_type: 'transfer_out').sum(:amount)
  end
  
  def allows_negative_balance?
    credit_card? || loan?
  end
  
  private
  
  def set_default_balance
    self.balance ||= 0.0
  end
end
