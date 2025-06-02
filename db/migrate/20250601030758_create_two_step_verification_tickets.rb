class CreateTwoStepVerificationTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :two_step_verification_tickets do |t|
      t.references :account, null: false, foreign_key: true
      t.string :ticket
      t.datetime :expires_at

      t.timestamps
    end
  end
end
