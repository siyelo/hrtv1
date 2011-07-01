class UsersController < ApplicationController
  # set the user's 'current response' based on the given Request id
  def set_request
    change_user_current_response(DataRequest.find(params[:id]))
    redirect_to :back
  end

  # set the user's 'current response' to the one associated with the latest Request
  def set_latest_request
    current_user.set_current_response_to_latest!
    flash[:notice] = latest_request_message(current_user.current_response.request)
    redirect_to :back
  end
end
