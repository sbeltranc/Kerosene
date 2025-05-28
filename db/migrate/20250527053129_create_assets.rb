class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.string :name
      t.string :description
      t.references :creator, null: false, foreign_key: { to_table: :accounts }
      t.string :s3hash
      t.string :marhash
      t.string :marchecksum
      t.integer :version, default: 1

      t.timestamps
    end
  end
end
