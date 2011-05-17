class ClassificationsController < Reporter::BaseController
  before_filter :load_data_response

  def edit
    @projects = @response.projects.all
  end
end
