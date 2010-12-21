class PolicyMaker::DataResponsesController < ApplicationController
  layout 'admin'
  before_filter :require_admin
  skip_before_filter :load_help

  def index
    @submitted_data_responses = DataResponse.available_to(current_user).submitted.all
    @in_progress_data_responses = DataResponse.available_to(current_user).in_progress
    @empty_data_responses = DataResponse.available_to(current_user).empty
  end

  def show
    @data_response               = DataResponse.find(params[:id])
    @projects                    = @data_response.projects.find(:all, :order => "name ASC")
    @activities_without_projects = @data_response.activities.roots.without_a_project
    @code_roots                  = Code.for_activities.roots
    @cost_cat_roots              = CostCategory.roots
    @other_cost_roots            = OtherCostCode.roots
    @policy_maker                = true #view helper
  end
end
