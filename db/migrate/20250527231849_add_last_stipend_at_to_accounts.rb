class AddLastStipendAtToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :last_stipend_at, :datetime
  end
end
