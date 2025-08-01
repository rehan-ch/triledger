# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create default roles if they don't exist
roles = [
  { name: 'System Administrator', description: 'Full system access and control' },
  { name: 'HR Manager', description: 'Human resources management' },
  { name: 'Manager', description: 'Department management' },
  { name: 'Employee', description: 'Standard employee access' },
  { name: 'Finance Manager', description: 'Financial management and reporting' },
  { name: 'Accountant', description: 'Accounting and bookkeeping' }
]

roles.each do |role_attrs|
  Role.find_or_create_by!(name: role_attrs[:name]) do |role|
    role.description = role_attrs[:description]
  end
end

# Create sample users and employees
users = [
  { email: 'john.doe@company.com', first_name: 'John', last_name: 'Doe', phone: '123-456-7890' },
  { email: 'jane.smith@company.com', first_name: 'Jane', last_name: 'Smith', phone: '123-456-7891' },
  { email: 'mike.johnson@company.com', first_name: 'Mike', last_name: 'Johnson', phone: '123-456-7892' }
]

users.each do |user_attrs|
  user = User.find_or_create_by!(email: user_attrs[:email]) do |u|
    u.first_name = user_attrs[:first_name]
    u.last_name = user_attrs[:last_name]
    u.phone = user_attrs[:phone]
    u.password = 'password123'
  end
  
  # Create employee for each user
  employee_id = "EMP#{user.id.to_s.rjust(3, '0')}"
  employee = Employee.find_or_create_by!(employee_id: employee_id) do |e|
    e.user = user
    e.department = ['IT', 'HR', 'Finance', 'Marketing'].sample
    e.position = ['Developer', 'Manager', 'Analyst', 'Specialist'].sample
    e.hire_date = Date.current - rand(1..365).days
    e.status = 'active'
    e.salary = rand(40000..80000)
  end
  
  # Assign a random role
  role = Role.all.sample
  employee.add_role(role.name) unless employee.has_role?(role.name)
end

# Create sample accounts
accounts = [
  { name: 'Main Bank Account', account_type: 'bank', balance: 50000.00, description: 'Primary business bank account' },
  { name: 'Cash Register', account_type: 'cash', balance: 2500.00, description: 'Daily cash operations' },
  { name: 'Credit Card', account_type: 'credit_card', balance: -1500.00, description: 'Business credit card' },
  { name: 'Investment Account', account_type: 'investment', balance: 25000.00, description: 'Investment portfolio' },
  { name: 'Petty Cash', account_type: 'petty_cash', balance: 500.00, description: 'Small expenses fund' },
  { name: 'Savings Account', account_type: 'savings', balance: 15000.00, description: 'Emergency fund' }
]

accounts.each do |account_attrs|
  Account.find_or_create_by!(name: account_attrs[:name]) do |account|
    account.account_type = account_attrs[:account_type]
    account.balance = account_attrs[:balance]
    account.description = account_attrs[:description]
  end
end

# Create sample transactions
if Transaction.count == 0
  main_account = Account.find_by(name: 'Main Bank Account')
  cash_account = Account.find_by(name: 'Cash Register')
  credit_card = Account.find_by(name: 'Credit Card')
  employees = Employee.all
  
  transactions = [
    # Income transactions
    { account: main_account, transaction_type: 'income', amount: 5000.00, category: 'salary', description: 'Monthly salary payment', transaction_date: Date.current - 5.days, reference: 'SAL-001' },
    { account: main_account, transaction_type: 'income', amount: 2500.00, category: 'consulting', description: 'Consulting services', transaction_date: Date.current - 3.days, reference: 'CON-001' },
    { account: main_account, transaction_type: 'income', amount: 1000.00, category: 'bonus', description: 'Performance bonus', transaction_date: Date.current - 1.day, reference: 'BON-001' },
    
    # Expense transactions
    { account: main_account, transaction_type: 'expense', amount: 1500.00, category: 'rent', description: 'Office rent payment', transaction_date: Date.current - 7.days, reference: 'RENT-001' },
    { account: main_account, transaction_type: 'expense', amount: 800.00, category: 'utilities', description: 'Electricity and water bills', transaction_date: Date.current - 6.days, reference: 'UTIL-001' },
    { account: main_account, transaction_type: 'expense', amount: 300.00, category: 'office_supplies', description: 'Office supplies purchase', transaction_date: Date.current - 4.days, reference: 'SUP-001' },
    { account: credit_card, transaction_type: 'expense', amount: 200.00, category: 'meals', description: 'Business lunch', transaction_date: Date.current - 2.days, reference: 'MEAL-001' },
    
    # Loan transactions with employees
    { account: main_account, transaction_type: 'loan', amount: 5000.00, category: 'personal_loan', description: 'Personal loan for John Doe', transaction_date: Date.current - 10.days, reference: 'LOAN-001', employee: employees.first },
    { account: main_account, transaction_type: 'loan', amount: 3000.00, category: 'car_loan', description: 'Car loan for Jane Smith', transaction_date: Date.current - 8.days, reference: 'LOAN-002', employee: employees.second },
    { account: main_account, transaction_type: 'loan', amount: 8000.00, category: 'business_loan', description: 'Business loan for Mike Johnson', transaction_date: Date.current - 12.days, reference: 'LOAN-003', employee: employees.third },
    
    # Transfer transactions
    { account: main_account, transaction_type: 'transfer_out', amount: 5000.00, category: 'bank_transfer', description: 'Transfer to investment account', transaction_date: Date.current - 8.days, reference: 'TRF-001' },
    { account: cash_account, transaction_type: 'transfer_in', amount: 1000.00, category: 'cash_transfer', description: 'Cash withdrawal for petty cash', transaction_date: Date.current - 9.days, reference: 'CASH-001' }
  ]
  
  transactions.each do |transaction_attrs|
    Transaction.create!(transaction_attrs)
  end
end

puts "Seed data created successfully!"
puts "Created #{Role.count} roles"
puts "Created #{User.count} users"
puts "Created #{Employee.count} employees"
puts "Created #{Account.count} accounts"
puts "Created #{Transaction.count} transactions"
