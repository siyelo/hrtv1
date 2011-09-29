class BaseController < ApplicationController
  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request

  protected

    # activity/new endpoint
    def load_activity_new
      @activity = Activity.new(:data_response_id => @response.id)
      @activity.project = @response.projects.find_by_id(params[:project_id]) if params[:project_id]
      # if you cant find an existing project with given params
      # then set it to -1 (i.e. Create a project for me)
      @activity.project_id = Activity::AUTOCREATE unless @activity.project
      @activity.provider = current_user.organization
    end

    # other_cost/new endpoint
    def load_other_cost_new
      @other_cost = OtherCost.new(:data_response_id => @response.id)
      @other_cost.project = @response.projects.find_by_id(params[:project_id]) if params[:project_id]
      # if you cant find an existing project with given params
      # then just leave it nil (i.e. it will be an "other cost without a project")
      @other_cost.data_response = @response
    end

    def html_redirect
      outlay = @activity || @other_cost
      if params[:commit] == "Save & Add Locations >"
        return redirect_to edit_activity_or_ocost_path(outlay, :mode => 'locations')
      elsif params[:commit] == "Save & Add Purposes >"
        return redirect_to edit_activity_or_ocost_path(outlay, :mode => 'purposes')
      elsif params[:commit] == "Save & Add Inputs >"
        return redirect_to edit_activity_or_ocost_path(outlay, :mode => 'inputs')
      elsif params[:commit] == "Save & Add Targets >"
        return redirect_to edit_activity_or_ocost_path(outlay, :mode => 'outputs')
      elsif params[:commit] == "Save & Go to Overview >"
        return redirect_to response_projects_path(outlay.response)
      else
        return redirect_to edit_activity_or_ocost_path(outlay, :mode => params[:mode])
      end
    end
end
