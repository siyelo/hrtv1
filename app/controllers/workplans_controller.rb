class WorkplansController < Reporter::BaseController
  before_filter :load_data_response

  def show
  end

  def edit
    @projects = @response.projects.all
  end
end
