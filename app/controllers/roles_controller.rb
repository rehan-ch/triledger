class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_role, only: [:show, :edit, :update, :destroy]

  def index
    @roles = Role.all
  end

  def show
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to roles_path, notice: 'Role was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @role.update(role_params)
      redirect_to roles_path, notice: 'Role was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @role.employees.any?
      redirect_to roles_path, alert: 'Cannot delete role that has employees assigned.'
    else
      @role.destroy
      redirect_to roles_path, notice: 'Role was successfully deleted.'
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :description)
  end
end
