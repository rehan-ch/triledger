# Create default roles
Role.create_default_roles

# Create admin user and employee (only if they don't exist)
admin_user = User.find_or_create_by(email: 'admin@company.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.phone = '123-456-7890'
  user.password = 'password123'
end

# Create or update admin employee
admin_employee = Employee.find_or_create_by(employee_id: 'ADMIN001') do |employee|
  employee.user = admin_user
  employee.department = 'IT'
  employee.position = 'System Administrator'
  employee.hire_date = Date.current
  employee.status = 'active'
  employee.salary = 80000
end

# Ensure admin has the System Administrator role
system_admin_role = Role.find_by(name: 'System Administrator')
if system_admin_role && !admin_employee.has_role?('System Administrator')
  admin_employee.add_role('System Administrator')
end

puts "Default roles and admin user created/updated successfully!"
