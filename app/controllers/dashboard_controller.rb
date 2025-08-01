class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Employee statistics
    @total_employees = Employee.count
    @active_employees = Employee.where(status: 'active').count
    @new_employees_this_month = Employee.where('hire_date >= ?', Date.current.beginning_of_month).count
    
    # Department statistics
    @employees_by_department = Employee.group(:department).count
    @top_departments = @employees_by_department.sort_by { |_, count| -count }.first(5)
    
    # Role statistics
    @roles = Role.includes(:employees).all
    @role_distribution = @roles.map { |role| { name: role.name, count: role.employees.count } }
    
    # Recent activity
    @recent_employees = Employee.includes(:user).order(created_at: :desc).limit(5)
    @recent_hires = Employee.includes(:user).where('hire_date >= ?', 30.days.ago).order(hire_date: :desc).limit(5)
    
    # Status distribution
    @status_distribution = Employee.group(:status).count
    
    # Finance statistics
    @total_accounts = Account.count
    @total_balance = Account.sum(:balance)
    @total_income = Transaction.total_by_type_and_period('income')
    @total_expenses = Transaction.total_by_type_and_period('expense')
    @net_balance = @total_income - @total_expenses
    @recent_transactions = Transaction.includes(:account).recent.limit(5)
    
    # Quick actions based on user role
    @quick_actions = get_quick_actions
    
    # Notifications and alerts
    @notifications = get_notifications
  end

  private

  def get_quick_actions
    actions = []
    
    if current_user.has_role?('System Administrator')
      actions << { title: 'Manage Employees', path: employees_path, icon: 'users', color: 'blue' }
      actions << { title: 'Manage Roles', path: roles_path, icon: 'shield', color: 'green' }
      actions << { title: 'System Settings', path: '#', icon: 'settings', color: 'purple' }
    end
    
    if current_user.has_any_role?('System Administrator', 'Manager', 'HR Manager')
      actions << { title: 'Add Employee', path: new_employee_path, icon: 'user-plus', color: 'green' }
      actions << { title: 'View Reports', path: '#', icon: 'chart-bar', color: 'orange' }
    end
    
    # Finance actions
    actions << { title: 'View Accounts', path: accounts_path, icon: 'wallet', color: 'indigo' }
    actions << { title: 'New Transaction', path: new_transaction_path, icon: 'plus-circle', color: 'green' }
    actions << { title: 'View Transactions', path: transactions_path, icon: 'list', color: 'blue' }
    
    actions << { title: 'My Profile', path: profile_path, icon: 'user', color: 'gray' }
    actions << { title: 'Help & Support', path: '#', icon: 'question-circle', color: 'blue' }
    
    actions
  end

  def get_notifications
    notifications = []
    
    # Check for employees without roles
    employees_without_roles = Employee.joins(:employee_roles).group('employees.id').having('COUNT(employee_roles.id) = 0')
    if employees_without_roles.exists?
      notifications << {
        type: 'warning',
        message: "#{employees_without_roles.count} employee(s) without assigned roles",
        action: 'Review employees'
      }
    end
    
    # Check for recent terminations
    recent_terminations = Employee.where(status: 'terminated', updated_at: 7.days.ago..Time.current)
    if recent_terminations.exists?
      notifications << {
        type: 'info',
        message: "#{recent_terminations.count} employee(s) terminated in the last 7 days",
        action: 'View details'
      }
    end
    
    # Finance notifications
    if @total_balance < 0
      notifications << {
        type: 'warning',
        message: "Negative account balance detected",
        action: 'Review accounts'
      }
    end
    
    if @total_expenses > @total_income
      notifications << {
        type: 'warning',
        message: "Expenses exceed income this period",
        action: 'Review transactions'
      }
    end
    
    notifications
  end
end
