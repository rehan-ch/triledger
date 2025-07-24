class CreateDefaultRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :default_roles do |t|
      t.timestamps
    end
  end
end
