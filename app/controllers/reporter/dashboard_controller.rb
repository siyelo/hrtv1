class Reporter::DashboardController < Reporter::BaseController

  def index
    @requests       = current_user.organization.unfulfilled_data_requests
    @responses      = current_user.data_responses
    @comments       = Comment.on_all(current_user.organization).limit(5)
    @user           = current_user
  end
  
  def change_data_response
    result = current_user.change_data_response(params[:user][:data_response_id_current])
    if result
      datarequest = DataResponse.find(current_user.data_response_id_current).data_request
      message = datarequest.current_request?
      message ? flash[:notice] = "You have sucessfully changed your data response" : flash[:error] = "You have sucessfully changed your data response. You are not currently working with the latest data"
    else
      flash[:error] = "Sorry we could not complete that action"
    end
    redirect_to :back
  end
end

