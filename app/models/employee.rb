class Employee < ApplicationRecord
  belongs_to :user
  has_many :employee_roles, dependent: :destroy
  has_many :roles, through: :employee_roles
  
  accepts_nested_attributes_for :user
  
  validates :employee_id, presence: true, uniqueness: true
  validates :hire_date, presence: true
  validates :status, presence: true

  
  # Employee statuses - Fixed enum declaration
  enum :status, {
    active: 'active',
    inactive: 'inactive', 
    terminated: 'terminated',
    on_leave: 'on_leave'
  }
  
  def full_name
    "#{user.first_name} #{user.last_name}"
  end
  
  # Check if employee has a specific role
  def has_role?(role_name)
    roles.exists?(name: role_name)
  end
  
  # Check if employee has any of the specified roles
  def has_any_role?(*role_names)
    roles.where(name: role_names).exists?
  end
  
  # Add role to employee
  def add_role(role_name)
    role = Role.find_by(name: role_name)
    roles << role if role && !has_role?(role_name)
  end
  
  # Remove role from employee
  def remove_role(role_name)
    role = roles.find_by(name: role_name)
    roles.delete(role) if role
  end
end
