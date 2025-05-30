class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :account, null: false, foreign_key: true
      t.datetime :expires_at
      t.integer :type

      t.timestamps
    end
  end
end
