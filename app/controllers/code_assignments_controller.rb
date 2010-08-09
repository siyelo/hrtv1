class CodeAssignmentsController < ApplicationController
  authorize_resource

  def budget
    self.load_codes
    @current_codes = @activity.budget_codes
    @current_assignments = @activity.budget_codings
    @coding_type = :budget_codes
  end

  def budget_cost_categories
    self.load_codes
    @current_codes = @activity.budget_codes
    @current_assignments = @activity.budget_codings
    @coding_type = :budget_cost_categories
    @codes = @activity.valid_cost_category_codes
  end

  def expenditure
    self.load_codes
    @current_codes = @activity.expenditure_codes
    @current_assignments = @activity.expenditure_codings
    @coding_type = :expenditure_codes
  end

  def expenditure_cost_categories
    self.load_codes
    @current_codes = @activity.expenditure_codes
    @current_assignments = @activity.expenditure_codings
    @coding_type = :expenditure_cost_categories
    @codes = @activity.valid_cost_category_codes
  end

  def update_budget
    @activity = Activity.find(params[:activity_id])
    self.update_assignments("budget", budget_activity_coding_path(@activity))
  end

  def update_expenditure
    @activity = Activity.find(params[:activity_id])
    self.update_assignments("expenditure", expenditure_activity_coding_path(@activity))
  end

  def update_budget_cost_categories
    @activity = Activity.find(params[:activity_id])
    self.update_assignments("budget", budget_cost_categories_activity_coding_path(@activity))
  end

  def update_expenditure_cost_categories
    @activity = Activity.find(params[:activity_id])
    self.update_assignments("expenditure", expenditure_cost_categories_activity_coding_path(@activity))
  end
  protected

  def load_codes
    @activity = Activity.find(params[:activity_id])
    authorize! :read, @activity
    @codes = @activity.valid_roots_for_code_assignment
  end

  def update_assignments(coding_type, path)
    #authorize! :update, @activity #GN: why is this missing
    params[:activity].delete(:code_assignment_tree) #until we figure out how to remove the checkbox inputs

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = "Activity #{coding_type} was successfully updated."
        format.html { redirect_to(path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "manage" } #TODO fix path here
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

end
