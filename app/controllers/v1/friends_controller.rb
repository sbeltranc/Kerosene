class V1::FriendsController < ApplicationController
  # GET /v1/metadata
  def metadata
    targetUserId = params[:targetUserId]

    username = nil
    displayName = nil

    if !targetUserId.nil? && !targetUserId.empty?
      targetUser = User.find_by(id: targetUserId)
      if targetUser
        username = targetUser.username
        displayName = targetUser.display_name
      end
    end

    render json: {
      isFriendsFilterBarEnabled: false,
      isFriendsPageSortExperimentEnabled: false,
      isFriendsUserDataStoreCacheEnabled: false,
      frequentFriendSortRollout: 0,

      userName: username,
      displayName: displayName
    }, status: :ok
  end

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
