class AddEmployeeToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_reference :transactions, :employee, null: true, foreign_key: true
  end
end
