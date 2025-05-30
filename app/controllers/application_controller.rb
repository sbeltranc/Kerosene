class ApplicationController < ActionController::API
  include ActionController::Cookies

  def route_not_found
    render json: respond_with_error(0, "NotFound"), status: :not_found
  end

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
      if session.ip != request.remote_ip
        session.destroy
        cookies.delete(".ROBLOSECURITY")
        return nil
      end

      session.update(last_seen_at: Time.current)
      session.account
    end
  end
end
