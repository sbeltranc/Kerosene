class CreateAssetCaches < ActiveRecord::Migration[8.0]
  def change
    create_table :asset_caches do |t|
      t.string :assetid
      t.string :filehash
      t.integer :assettypeid
      t.string :token
      t.datetime :expiration

      t.timestamps
    end
  end
end
