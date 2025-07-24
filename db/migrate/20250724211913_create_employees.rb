class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.references :user, null: false, foreign_key: true
      t.string :employee_id
      t.string :department
      t.string :position
      t.date :hire_date
      t.string :status
      t.decimal :salary
      t.text :address
      t.string :emergency_contact_name
      t.string :emergency_contact_phone

      t.timestamps
    end
  end
end
