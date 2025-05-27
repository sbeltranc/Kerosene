class ModifyPastUsernames < ActiveRecord::Migration[8.0]
  def change
    rename_column :past_usernames, :oldusername, :username
  end
end
