class CreateFriends < ActiveRecord::Migration[8.0]
  def change
    create_table :friends do |t|
      t.references :sent_by, null: false, foreign_key: { to_table: :accounts }
      t.references :sent_to, null: false, foreign_key: { to_table: :accounts }
      t.string :status

      t.timestamps
    end
  end
end
