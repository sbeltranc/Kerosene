class V1::UsersController < ApplicationController
  # GET /v1/birthdate
  def birthdate
    if current_account
      render json: {
        birthDay: 11,
        birthMonth: 9,
        birthYear: 2001
      }
    else
      render json: respond_with_error(0, "Authorization has been denied for this request."), status: :unauthorized
    end
  end

  # GET /v1/description
  def description
    if current_account
      render json: { description: current_account.description || "" }
    else
      render json: respond_with_error(0, "Authorization has been denied for this request."), status: :unauthorized
    end
  end

  # GET /v1/gender
  def gender
    if current_account
      render json: { gender: 0 }
    else
      render json: respond_with_error(0, "Authorization has been denied for this request."), status: :unauthorized
    end
  end

  # POST /v1/description
  def update_description
    if !is_allowed_todo_action
      return
    end

    if current_account
      new_description = params[:description]

      if new_description.nil? || new_description.strip.empty?
        render json: respond_with_error(1, "Description cannot be empty."), status: :bad_request
      end

      if new_description.length > 1000
        render json: respond_with_error(2, "Description is too long. Maximum length is 1000 characters."), status: :bad_request
      else
        current_account.update(description: new_description)
        render json: { description: current_account.description }, status: :ok
      end
    end
  end

  # POST /v1/gender
  def update_gender
    render json: {}, status: :ok
  end

  # POST /v1/birthdate
  def update_birthdate
    render json: {}, status: :ok
  end

  # GET /v1/users/authenticated
  def authenticated
    if current_account
      render json: {
        id: current_account.id,
        name: current_account.username,
        displayName: current_account.username,
        description: current_account.description,
        created: current_account.created_at.iso8601,
        isBanned: current_account.is_account_banned,
        isVerified: current_account.verified
      }
    else
      render json: respond_with_error(0, "User not authenticated"), status: :unauthorized
    end
  end

  # GET /v1/users/authenticated/age-bracket
  def authenticated_age_bracket
    if current_account
      render json: { ageBracket: 0 }
    else
      render json: respond_with_error(0, "Authorization has been denied for this request."), status: unauthorized
    end
  end

  # GET /v1/users/authenticated/country-code
  def authenticated_country_code
    if current_account
      render json: { countryCode: request.headers["CF-IPCountry"] || "US" }
    else
      render json: respond_with_error(0, "Authorization has been denied for this request."), status: :unauthorized
    end
  end

  # GET /v1/users/:id/username-history
  def username_history
    account = Account.find_by(id: params[:id])

    if account
      render json: {
        previousPageCursor: nil,
        nextPageCursor: nil,

        data: account.past_usernames.where(ismoderated: false).select(:username)
      }
    else
      render json: respond_with_error(0, "User not found"), status: :not_found
    end
  end

  # GET /v1/users/authenticated/roles
  def authenticated_roles
    if current_account
      render json: { roles: current_account.roles.pluck(:role) }
    else
      render json: respond_with_error(0, "Authorization has been denied for this request."), status: :unauthorized
    end
  end

  # GET /v1/users/:id
  def show
    account = Account.find_by(id: params[:id])

    if account
      render json: {
        id: account.id,
        name: account.username,
        displayName: account.username,
        description: account.description,
        created: account.created_at.iso8601,
        isBanned: false
      }
    else
      render json: respond_with_error(0, "User not found"), status: :not_found
    end
  end
end
