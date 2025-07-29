class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Employee association
  has_one :employee, dependent: :destroy
  
  # Validations for user profile
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone, presence: true
  
  # Override Devise password validation to be conditional
  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # Delegate employee methods to employee
  delegate :has_role?, :has_any_role?, :add_role, :remove_role, to: :employee, allow_nil: true
end
