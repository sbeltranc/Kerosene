class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :role
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
