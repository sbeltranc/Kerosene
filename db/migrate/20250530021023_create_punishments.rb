class CreatePunishments < ActiveRecord::Migration[8.0]
  def change
    create_table :punishments do |t|
      t.string :simuldev_id
      t.datetime :expires_at
      t.string :reason
      t.integer :type
      t.boolean :confirmed

      t.timestamps
    end
  end
end
