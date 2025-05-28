class AddColumnsToAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :assets, :latest_version, :integer
    add_column :assets, :parent_asset_version_id, :bigint
    add_column :assets, :creator_type, :string
    add_column :assets, :creator_target_id, :bigint
  end
end
