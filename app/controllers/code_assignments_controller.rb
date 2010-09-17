class CodeAssignmentsController < ApplicationController
  authorize_resource

  def show
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    authorize! :read, @activity

    @coding_type = params[:coding_type] || 'budget_codes'
    @codes = @activity.get_codes(@coding_type)
    @current_assignments = @activity.get_current_assignments(@coding_type)

    if params[:tab].present?
      # ajax requests for all tabs except the first one
      render :partial => 'tab', :locals => { :coding_type => @coding_type, :activity => @activity, :codes => @codes, :tab => params[:tab] }, :layout => false
    else
      # show page with first tab loaded
      @model_help = ModelHelp.find_by_model_name 'CodeAssignment'
      render :action => 'show'
    end
  end

  def update
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    authorize! :update, @activity
    params[:activity].delete(:code_assignment_tree) #until we figure out how to remove the checkbox inputs

    if @activity.update_attributes(params[:activity])
      flash[:notice] = "Activity #{params[:coding_type].to_s.split('_').first} was successfully updated."
    end

    redirect_to activity_coding_path(@activity)
  end
end
