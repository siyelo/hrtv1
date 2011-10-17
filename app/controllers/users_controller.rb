class UsersController < ApplicationController
  before_filter :require_user
  before_filter :require_activity_manager, :only => [:activity_manager_workplan]

  # set the user's 'current response' based on the given Request id
  def set_request
    if current_user.district_manager?
      session[:request_id] = DataRequest.find(params[:id]).id
    else
      current_user.change_current_response!(params[:id])
      if current_user.current_response_is_latest?
        flash[:notice] = request_message(current_user.current_response.request)
      end
    end


    redirect_back
  end

  # set the user's 'current response' to the one associated with the latest Request
  def set_latest_request
    current_user.set_current_response_to_latest!
    flash[:notice] = request_message(current_user.current_response.request)
    redirect_back
  end

  def activity_manager_workplan
    workplan = Reports::ActivityManagerWorkplan.new(current_user.current_response, current_user.organizations)
    send_xls(workplan.to_xls,"combined_workplan.xls")
  end

  private

    def redirect_back
      redirect_to :back
    rescue ActionController::RedirectBackError
      redirect_to dashboard_path
    end
end
