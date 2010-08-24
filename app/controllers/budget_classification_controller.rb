class BudgetClassificationController < ApplicationController

  def show
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    authorize! :read, @activity
    @codes = @activity.valid_roots_for_code_assignment

    # cache the code_assignment in a hash keyed by the code id
    # (makes the view rendering 57% less enterprisey)
    @current_assignments = @activity.budget_codings.map_to_hash{ |b| {b.code_id => b} }
    @coding_type         = :budget
    @model_help          = ModelHelp.find_by_model_name "CodeAssignment"
  end

  def update
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    authorize! :update, @activity
    params[:activity].delete(:code_assignment_tree) #until we figure out how to remove the checkbox inputs

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = "Activity budget was successfully updated."
        format.html { redirect_to( activity_budget_path(@activity) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "manage" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

end
