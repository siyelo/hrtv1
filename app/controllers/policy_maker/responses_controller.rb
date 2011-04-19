class PolicyMaker::ResponsesController < PolicyMaker::BaseController

  def index
    @submitted_data_responses = DataResponse.available_to(current_user).submitted.all
    @in_progress_data_responses = DataResponse.available_to(current_user).in_progress
    @empty_data_responses = DataResponse.available_to(current_user).empty
  end

  def show
    @data_response                = DataResponse.find(params[:id])
    @projects                     = @data_response.projects.find(:all, :order => "name ASC")
    @activities_without_projects  = @data_response.activities.roots.without_a_project
    @other_costs_without_projects = @data_response.other_costs.without_a_project
    @code_roots                   = Code.purposes.roots
    @cost_cat_roots               = CostCategory.roots
    @other_cost_roots             = OtherCostCode.roots
    @policy_maker                 = true #view helper
  end
end
