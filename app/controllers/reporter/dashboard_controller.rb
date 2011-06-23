class Reporter::DashboardController < Reporter::BaseController

  def index
    @responses      = current_user.organization.data_responses.ordered.all
    @comments       = Comment.on_all(current_user.organization).limit(5)
    @user           = current_user
  end

  def change_data_response
    user = current_user
    response = user.responses.find(params[:user][:data_response_id_current])
    if response
      user.data_response_id_current = response.id
      if user.save
        user.reload #otherwise current_response association is stale
        request = user.current_response.request
        if user.current_response_is_latest?
          flash[:notice] = "You are now viewing your data for the latest Request: \"<span class='bold'>#{request.name}</span>\""
        end
      else
        flash[:error] = "Sorry we could not update your response"
      end
    else
      flash[:error] = "Sorry we could not find that response"
    end
    redirect_to :back
  end

  def set_latest_response
    current_user.set_current_response_to_latest!
    request = current_user.current_response.request
    flash[:notice] = "You are now viewing your data for the latest Request: \"<span class='bold'>#{request.name}</span>\""
    redirect_to :back
  end
end

