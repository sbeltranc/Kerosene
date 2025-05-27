require "uri"
require "json"
require "net/http"

class V2::AuthController < ApplicationController
  include ActionController::Cookies

  # POST /v2/login
  def login
    login_type = params[:ctype]
    login_value = params[:cvalue]

    password = params[:password]
    captchaToken = params[:captchaToken]

    # checking if the parameters are present for authentication
    if login_type.nil?
      render json: respond_with_error(3, "Username and Password are required. Please try again."), status: :forbidden
      return nil
    end

    if login_value.nil?
      render json: respond_with_error(3, "Username and Password are required. Please try again."), status: :forbidden
      return nil
    end

    if password.nil?
      render json: respond_with_error(3, "Username and Password are required. Please try again."), status: :forbidden
      return nil
    end

    # validating the login type if it's present for us
    if ![ "Email", "Username" ].include?(login_type)
      render json: respond_with_error(8, "Login with received credential type is not supported."), status: :forbidden
      return nil
    end

    # validating the captcha
    if captchaToken.nil?
      render json: respond_with_error(2, "You must pass the robot test before logging in."), status: :forbidden
      return nil
    end

    # if !verify_captcha(captchaToken, request.remote_ip)
    #  render json: respond_with_error(2, "You must pass the robot test before logging in."), status: :forbidden
    #  return nil
    # end

    # finding the account based on the login value
    account = nil

    if login_type == "Username"
      account = Account.find_by(username: login_value)
    elsif login_type == "Email"
      account = Account.find_by(email: login_value)
    end

    if account.nil?
      render json: respond_with_error(1, "Incorrect username or password. Please try again."), status: :forbidden
      return nil
    end

    # checking if the password is correct
    if account.authenticate(password)
      session_token = SecureRandom.hex(16)

      Session.create!(
        ip: request.remote_ip,
        token: session_token,
        account: account,
        last_seen_at: Time.current,
      )

      cookies[:'.ROBLOSECURITY'] = {
        value: session_token,
        httponly: true,
        secure: Rails.env.production? || false
      }

      render json: {
        user: {
          id: account.id,
          name: account.username,
          displayName: account.username
        },

        isBanned: false
      }, status: :ok
    else
      render json: respond_with_error(1, "Incorrect username or password. Please try again."), status: :forbidden
    end
  end

  # POST /v2/signup
  def signup
    username = params[:username]
    password = params[:password]
    email = params[:email]
    captchaToken = params[:captchaToken]

    # checking if the parameters are present for authentication
    if email.nil? || !URI::MailTo::EMAIL_REGEXP.match?(email)
      render json: respond_with_error(10, "Email is invalid."), status: :forbidden
      return nil
    end

    if username.nil? || username.empty? || username.length < 3 || username.length > 20
      render json: respond_with_error(5, "Invalid Username."), status: :forbidden
      return nil
    end

    if password.nil? || password.empty? || password.length < 6 || password.length > 20
      render json: respond_with_error(7, "Invalid Password."), status: :forbidden
      return nil
    end

    # check if email or username already exists
    if Account.find_by(username: username)
      render json: respond_with_error(4, "Username already taken."), status: :forbidden
      return nil
    end

    if Account.find_by(email: email)
      render json: respond_with_error(6, "Email already taken."), status: :forbidden
      return nil
    end

    # validating the captcha
    if captchaToken.nil?
      render json: respond_with_error(2, "You must pass the robot test before signing up."), status: :forbidden
      nil
    end

    # we are ready to go, let's create the account
    account = Account.create!(
      username: username,
      email: email,
      password: password,
      last_seen_at: Time.current,

      status: "Hi there!",
      description: "",
      balance: 500
    )

    if account.save
      session_token = SecureRandom.hex(16)

      Session.create!(
        account: account,
        token: session_token,
        ip: request.remote_ip,
        last_seen_at: Time.current,
      )

      cookies[:'.ROBLOSECURITY'] = {
        value: session_token,
        httponly: true,
        secure: Rails.env.production? || false
      }

      render json: {
        userId: account.id
      }, status: :created
    else
      render json: respond_with_error(0, "Service unavailable"), status: :internal_server_error
    end
  end
end
