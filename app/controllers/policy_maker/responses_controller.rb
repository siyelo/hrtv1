class PolicyMaker::ResponsesController < PolicyMaker::BaseController

  def index
    @submitted_data_responses   = DataResponse.submitted.all
    @in_progress_data_responses = DataResponse.in_progress
    @empty_data_responses       = DataResponse.empty
  end

  def show
    @response                     = DataResponse.find(params[:id])
    @projects                     = @response.projects.find(:all, :order => "name ASC")
    @activities_without_projects  = @response.activities.roots.without_a_project
    @other_costs_without_projects = @response.other_costs.without_a_project
    @code_roots                   = Code.purposes.roots
    @cost_cat_roots               = CostCategory.roots
    @other_cost_roots             = OtherCostCode.roots
    @policy_maker                 = true #view helper
  end
end
