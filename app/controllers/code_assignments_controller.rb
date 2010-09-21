class CodeAssignmentsController < ApplicationController
  authorize_resource

  def show
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    authorize! :read, @activity

    @coding_type = params[:coding_type] || 'CodingBudget'
    coding_class = @coding_type.constantize

    @codes = coding_class.available_codes(@activity)
    @current_assignments = coding_class.with_activity(@activity).all.map_to_hash{ |b| {b.code_id => b} }

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

    coding_class = params[:coding_type].constantize
    coding_class.update_codings(params[:activity][:updates], @activity)
    flash[:notice] = "Activity coding was successfully updated."

    redirect_to activity_coding_path(@activity)
  end
end
