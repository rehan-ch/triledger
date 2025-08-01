class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :transaction_type, null: false
      t.decimal :amount, precision: 15, scale: 2
      t.text :description
      t.string :reference
      t.date :transaction_date
      t.string :category

      t.timestamps
    end
    
    add_index :transactions, :transaction_type
    add_index :transactions, :category
    add_index :transactions, :reference
  end
end
