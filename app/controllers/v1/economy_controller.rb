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
      account.update(balance: account.balance + 250, last_stipend_at: Time.current)
    end
  end
end
