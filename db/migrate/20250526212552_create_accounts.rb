class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username, null: false, unique: true
      t.string :email, null: false, unique: true
      t.datetime :last_seen_at
      t.decimal :balance, default: 0, precision: 12, scale: 2
      t.string :status, default: 'active'
      t.text :description
      t.string :password_digest
      t.timestamps
    end
  end
end
