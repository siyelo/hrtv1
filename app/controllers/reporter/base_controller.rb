class Reporter::BaseController < ApplicationController
  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request

  protected

    def html_redirect
      if params[:commit] == "Save & Add Locations >"
        return redirect_to edit_activity_or_ocost_path(@activity, :mode => 'locations')
      elsif params[:commit] == "Save & Add Purposes >"
        return redirect_to edit_activity_or_ocost_path(@activity, :mode => 'purposes')
      elsif params[:commit] == "Save & Add Inputs >"
        return redirect_to edit_activity_or_ocost_path(@activity, :mode => 'inputs')
      elsif params[:commit] == "Save & Add Outputs >"
        return redirect_to edit_activity_or_ocost_path(@activity, :mode => 'outputs')
      else
        return redirect_to edit_activity_or_ocost_path(@activity, :mode => params[:mode])
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
