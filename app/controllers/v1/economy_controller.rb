class V1::EconomyController < ApplicationController
  # GET /v1/user/currency
  def currency
    if current_account
      give_stipend_if_due(current_account)
      render json: { robux: current_account.balance.to_i }, status: :ok
    else
      render json: respond_with_error(0, "Authorization has been denied for this request."), status: :unauthorized
    end
  end

  def give_stipend_if_due(account)
    if account.last_stipend_at.nil? || account.last_stipend_at < 24.hours.ago
      base_stipend = 250

      multiplier = case account.active_membership&.membership_type
      when 1 then 2.0 # Builders Club
      when 2 then 2.5 # Turbo Builders Club
      when 3 then 3.0 # Outrageous Builders Club
      else 1          # No membership
      end

      stipend = base_stipend * multiplier

      account.update!(
        balance: account.balance + stipend,
        last_stipend_at: Time.current
      )
    end
  end
end
