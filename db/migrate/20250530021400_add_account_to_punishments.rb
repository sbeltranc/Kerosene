class AddAccountToPunishments < ActiveRecord::Migration[8.0]
  def change
    add_reference :punishments, :account, null: false, foreign_key: true
  end
end
