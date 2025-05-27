class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.string :token, null: false
      t.references :account, null: false, foreign_key: true
      t.datetime :last_seen_at
      t.string :ip, null: false

      t.timestamps
    end
    add_index :sessions, :token, unique: true
  end
end
