class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @employee = @user.employee
    @recent_transactions = Transaction.includes(:account).where(employee: @employee).recent.limit(5) if @employee
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone)
  end
end
