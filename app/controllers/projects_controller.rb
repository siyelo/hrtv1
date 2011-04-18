require 'set'
class ProjectsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response'

  def index
    scope = @data_response.projects.scoped({})
    scope = scope.scoped(:conditions => ["UPPER(name) LIKE UPPER(:q)",
                                         {:q => "%#{params[:query]}%"}]) if params[:query]
    @projects = scope.paginate(:page => params[:page], :per_page => 10,
                               :order => sort_column + " " + sort_direction) # rails 2
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    create! do |success, failure|
      success.html { redirect_to response_projects_url(@data_response) }
    end
  end

  def update
    success = FundingFlow.create_flows(params)
    update! do |success, failure|
      success.html {
        flash[:error] = "We were unable to save your funding flows, please check your data and try again" if !success
        redirect_to response_projects_url(@data_response)
      }
      failure.html do
        load_comment_resources(resource)
        render :action => 'edit'
      end
    end
  end

  def show
    load_comment_resources(resource)
    show!
  end

  def bulk_edit
    @projects = @data_response.projects
  end

  def bulk_update
    success = FundingFlow.create_flows(params)
    flash[:notice] = "Your projects have been successfully updated"
    redirect_to response_projects_url
  end

  def download_template
    template = Project.download_template
    send_csv(template, 'projects_template.csv')
  end

  def create_from_file
    begin
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
    rescue
      flash[:error] = "Your CSV file does not seem to be properly formatted."
      redirect_to response_projects_path(@data_response)
    end
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
