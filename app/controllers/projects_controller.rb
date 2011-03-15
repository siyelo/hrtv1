class ProjectsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'description', 'spend', 'budget']

  inherit_resources
  actions :all, :except => :show
  respond_to :html
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response

  def index
    #@projects = @data_response.projects.order(sort_column + " " + sort_direction) # rails 3, sigh
    scope = @data_response.projects.scoped({})
    # search functionality
    scope = scope.scoped(:conditions => ["name LIKE :q",
                                         {:q => "%#{params[:query]}%"}]) if params[:query]
    @projects = scope.paginate(:page => params[:page],
                               :order => sort_column + " " + sort_direction) # rails 2
  end

  def create
    create!{ response_projects_url(@data_response) }
  end

  def update
    update!{ response_projects_url(@data_response) }
  end

  def destroy
    destroy! { response_projects_url(@data_response) }
  end

  protected

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def begin_of_association_chain
      @data_response
    end
end
