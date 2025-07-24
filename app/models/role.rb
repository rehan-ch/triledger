class Role < ApplicationRecord
  has_many :employee_roles, dependent: :destroy
  has_many :employees, through: :employee_roles
  
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  
  # Functional roles (not employment status)
  ROLES = {
    system_admin: 'System Administrator',
    manager: 'Manager',
    hr_manager: 'HR Manager',
    finance_manager: 'Finance Manager',
    sales_manager: 'Sales Manager',
    team_lead: 'Team Lead',
    senior_employee: 'Senior Employee',
    junior_employee: 'Junior Employee'
  }.freeze
  
  def self.create_default_roles
    ROLES.each do |key, name|
      find_or_create_by(name: name) do |role|
        role.description = "#{name} role with appropriate permissions"
      end
    end
  end
end
