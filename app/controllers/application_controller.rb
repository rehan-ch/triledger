class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  # Helper methods for authorization
  def require_system_admin
    unless current_user&.has_role?('System Administrator')
      redirect_to root_path, alert: 'Access denied. System Administrator privileges required.'
    end
  end

  def require_manager_or_admin
    unless current_user&.has_any_role?('System Administrator', 'Manager')
      redirect_to root_path, alert: 'Access denied. Manager or Administrator privileges required.'
    end
  end

  def require_hr_access
    unless current_user&.has_any_role?('System Administrator', 'HR Manager')
      redirect_to root_path, alert: 'Access denied. HR access required.'
    end
  end
  
  # Helper method to get current employee
  def current_employee
    current_user&.employee
  end
end
