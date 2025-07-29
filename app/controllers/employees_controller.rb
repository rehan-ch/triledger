class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  before_action :authorize_employee_access

  def index
    @employees = Employee.includes(:user, :roles).order('users.last_name, users.first_name')
    @employees = @employees.joins(:roles).where(roles: { name: params[:role] }) if params[:role].present?
  end

  def show
  end

  def new
    @employee = Employee.new
    @employee.build_user
    @roles = Role.all
  end

  def create
    @employee = Employee.new(employee_params)
    @roles = Role.all

    if @employee.save
      # Assign roles
      if params[:employee][:role_ids].present?
        params[:employee][:role_ids].each do |role_id|
          @employee.roles << Role.find(role_id) if role_id.present?
        end
      end

      redirect_to @employee, notice: 'Employee was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @roles = Role.all
  end

  def update
    @roles = Role.all

    if @employee.update(employee_params)
      # Update roles
      @employee.roles.clear
      if params[:employee][:role_ids].present?
        params[:employee][:role_ids].each do |role_id|
          @employee.roles << Role.find(role_id) if role_id.present?
        end
      end

      redirect_to @employee, notice: 'Employee was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_url, notice: 'Employee was successfully deleted.'
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    # Remove blank password fields for updates
    if params[:employee][:user_attributes].present?
      if params[:employee][:user_attributes][:password].blank?
        params[:employee][:user_attributes].delete(:password)
        params[:employee][:user_attributes].delete(:password_confirmation)
      end
    end
    
    params.require(:employee).permit(
      :employee_id, :hire_date, :status, :salary, 
      :address, :emergency_contact_name, :emergency_contact_phone,
      user_attributes: [:first_name, :last_name, :email, :phone, :password, :password_confirmation]
    )
  end

  def authorize_employee_access
    unless current_user.has_any_role?('System Administrator', 'Manager', 'HR Manager')
      redirect_to root_path, alert: 'You are not authorized to access employee management.'
    end
  end
end