class Reporter::BaseController < ApplicationController
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
      @activity.project_id = -1 unless @activity.project
      @activity.provider = current_user.organization
    end

    # other_cost/new endpoint
    def load_other_cost_new
      @other_cost = OtherCost.new
      @other_cost.project = @response.projects.find_by_id(params[:project_id]) if params[:project_id]
      # if you cant find an existing project with given params
      # then just leave it nil (i.e. it will be an "other cost without a project")
      @other_cost.data_response = @response
    end

    def html_redirect
      activity = @activity || @other_cost
      if params[:commit] == "Save & Add Locations >"
        return redirect_to edit_activity_or_ocost_path(activity, :mode => 'locations')
      elsif params[:commit] == "Save & Add Purposes >"
        return redirect_to edit_activity_or_ocost_path(activity, :mode => 'purposes')
      elsif params[:commit] == "Save & Add Inputs >"
        return redirect_to edit_activity_or_ocost_path(activity, :mode => 'inputs')
      elsif params[:commit] == "Save & Add Targets >"
        return redirect_to edit_activity_or_ocost_path(activity, :mode => 'outputs')
      elsif params[:commit] == "Save & Go To Project >"
        return redirect_to edit_response_project_path(activity.response, activity.project)
      else
        return redirect_to edit_activity_or_ocost_path(activity, :mode => params[:mode])
      end
    end

  private
    def js_redirect
      render :json => {:html => render_to_string(:partial => 'activities/bulk_edit',
                                       :layout => false,
                                       :locals => {:activity => @activity,
                                                   :response => @response})}
    end
end
