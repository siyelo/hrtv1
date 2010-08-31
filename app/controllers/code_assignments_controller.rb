class CodeAssignmentsController < ApplicationController
  authorize_resource
  before_filter :load_help

  def budget
    load_codes
    @current_codes = @activity.budget_codes
    @current_assignments = @activity.budget_codings.map_to_hash{ |b| {b.code_id => b} }
    @coding_type = :budget_codes
  end

  def budget_cost_categories
    load_codes
    @current_codes = @activity.budget_codes
    @current_assignments = @activity.budget_codings.map_to_hash{ |b| {b.code_id => b} }
    @coding_type = :budget_cost_categories
    @codes = @activity.valid_cost_category_codes
    render :layout => false
  end

  def budget_districts
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    authorize! :read, @activity
    @districts = @activity.districts
  end

  def expenditure
    load_codes
    @current_codes = @activity.expenditure_codes
    @current_assignments = @activity.expenditure_codings.map_to_hash{ |b| {b.code_id => b} }
    @coding_type = :expenditure_codes
    render :layout => false
  end

  def expenditure_cost_categories
    load_codes
    @current_codes = @activity.expenditure_codes
    @current_assignments = @activity.expenditure_codings.map_to_hash{ |b| {b.code_id => b} }
    @coding_type = :expenditure_cost_categories
    @codes = @activity.valid_cost_category_codes
    render :layout => false
  end

  def update_budget
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    update_assignments("budget")
  end

  def update_expenditure
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    update_assignments("expenditure")
  end

  def update_budget_cost_categories
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    update_assignments("budget")
  end

  def update_expenditure_cost_categories
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    update_assignments("expenditure")
  end
  protected

  def load_codes
    @activity = Activity.available_to(current_user).find(params[:activity_id])
    authorize! :read, @activity
    @codes = @activity.valid_roots_for_code_assignment
  end

  def update_assignments(coding_type)
    authorize! :update, @activity
    params[:activity].delete(:code_assignment_tree) #until we figure out how to remove the checkbox inputs

    if @activity.update_attributes(params[:activity])
      flash[:notice] = "Activity #{coding_type} was successfully updated."
      redirect_to(budget_activity_coding_path(@activity))
    else
      render :action => "manage" #TODO fix path here
    end
  end

  protected

  def load_help
    @model_help = ModelHelp.find_by_model_name 'CodeAssignment'
  end
end
