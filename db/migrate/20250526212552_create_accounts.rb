class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :username, null: false
      t.string :email, null: false
      t.datetime :last_seen_at
      t.decimal :balance, default: 0, precision: 12, scale: 2
      t.string :status, default: 'active'
      t.text :description
      t.string :password_digest
      t.timestamps
    end

    add_index :accounts, :username, unique: true
    add_index :accounts, :email, unique: true
  end
end
