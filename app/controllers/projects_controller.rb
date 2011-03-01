class ProjectsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'description', 'spend', 'budget']

  inherit_resources
  actions :all, :except => :show
  respond_to :html
  helper_method :sort_column, :sort_direction

  before_filter :load_data_response
  before_filter :load_resource, :only => [:edit, :update, :destroy]

  def index
    #@projects = @data_response.projects.order(sort_column + " " + sort_direction) # rails 3, sigh
    @projects = @data_response.projects.paginate(:page => params[:page], :order => sort_column + " " + sort_direction) # rails 2
    index!
  end

  def new
    @project = @data_response.projects.new()
    new!
  end

  def edit
    edit!
  end

  # check ownership and redirect to collection path on create instead of show
  def create
    @project = @data_response.projects.new(params[:project])
    create!{ response_projects_url(@data_response) }
  end

  # check ownership and redirect to collection path on update instead of show
  def update
    update!{ response_projects_url(@data_response) }
  end

  def destroy
    destroy! { response_projects_url(@data_response) }
  end

  protected

    def load_resource
      @project = @data_response.projects.find(params[:id])
    end

    def load_data_response
      @data_response = DataResponse.find(params[:response_id])
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
