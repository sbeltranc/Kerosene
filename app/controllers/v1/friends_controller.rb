class V1::FriendsController < ApplicationController
  # GET /v1/user/friend-requests/count
  def friend_requests_count
    if current_account
      friend_requests_count = FriendRequest.where(sent_to: current_account, status: :pending).count
      render json: { count: friend_requests_count }, status: :ok
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
