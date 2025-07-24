class EmployeeRole < ApplicationRecord
  belongs_to :employee
  belongs_to :role
  
  validates :employee_id, uniqueness: { scope: :role_id }
end
