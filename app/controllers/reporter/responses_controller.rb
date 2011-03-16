class Reporter::ResponsesController < Reporter::BaseController

  def show
    if current_user.admin?
      @data_response = DataResponse.find(params[:id])
    else
      @data_response = current_user.data_responses.find(params[:id])
    end
    @projects                    = @data_response.projects.find(:all, :order => "name ASC")
    @activities_without_projects = @data_response.activities.roots.without_a_project
    @code_roots                  = Code.for_activities.roots
    @cost_cat_roots              = CostCategory.roots
    @other_cost_roots            = OtherCostCode.roots
    @policy_maker                = true #view helper
  end
end
