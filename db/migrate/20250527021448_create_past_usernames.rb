class CreatePastUsernames < ActiveRecord::Migration[8.0]
  def change
    create_table :past_usernames do |t|
      t.string :username
      t.references :account, null: false, foreign_key: true
      t.boolean :ismoderated

      t.timestamps
    end
  end
end
