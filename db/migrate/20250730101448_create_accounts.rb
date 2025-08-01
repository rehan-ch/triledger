class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :account_type
      t.decimal :balance, precision: 15, scale: 2, default: 0.0, null: false
      t.text :description

      t.timestamps
    end
    
    add_index :accounts, :name, unique: true
  end
end
