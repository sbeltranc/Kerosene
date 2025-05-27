class ApplicationController < ActionController::API
  include ActionController::Cookies

  def respond_with_error(code, message)
    {
      errors: [
        {
          code: code,
          message: message,
          userFacingMessage: message
        }
      ]
    }
  end

  def verify_captcha(token, ip_address)
    secret_key = Rails.application.credentials.dig(:turnstile, :secret_key)

    uri = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")

    params = {
      secret: secret_key,
      response: token,
      remoteip: ip_address
    }

    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.post_form(uri, params)
    json = JSON.parse(response.body)

    json["success"] == true
  end

  private

  def current_account
    token = cookies[:'.ROBLOSECURITY']
    return nil unless token

    session = Session.find_by(token: token)

    if session
      session.update(last_seen_at: Time.current)
      session.account
    else
      nil
    end
  end

  def requires_authentication!
    unless current_account
      render json: respond_with_error(0, "User is not authenticated"), status: :forbidden
    end
  end
end
