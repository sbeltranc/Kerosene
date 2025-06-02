class Add2faToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :two_factor_enabled, :boolean, default: false
    add_column :accounts, :two_factor_secret, :string
  end
end
