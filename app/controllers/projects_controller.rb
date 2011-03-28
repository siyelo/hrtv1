require 'set'
class ProjectsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response'

  def index
    scope = @data_response.projects.scoped({})
    scope = scope.scoped(:conditions => ["name LIKE :q",
                                         {:q => "%#{params[:query]}%"}]) if params[:query]
    @projects = scope.paginate(:page => params[:page], :per_page => 10,
                               :order => sort_column + " " + sort_direction) # rails 2
  end

  def create
    create! {response_projects_url(@data_response)}
  end

  def update
    update! {response_projects_url(@data_response)}
  end

  def show
    @comment = Comment.new
    @comment.commentable = resource
    @comments = resource.comments.find(:all, :order => 'created_at DESC')
    show!
  end

  def download_template
    template = Project.download_template
    send_csv(template, 'projects_template.csv')
  end

  def create_from_file
    if params[:file].present?
      doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
      if doc.headers.to_set == Project::FILE_UPLOAD_COLUMNS.to_set
        saved, errors = Project.create_from_file(doc, @data_response)
        flash[:notice] = "Created #{saved} of #{saved + errors} projects successfully"
      else
        flash[:error] = 'Wrong fields mapping. Please download the CSV template'
      end
    else
      flash[:error] = 'Please select a file to upload'
    end

    redirect_to response_projects_url(@data_response)
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
