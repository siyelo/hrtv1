require 'set'
class ProjectsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response', :instance_name => 'response'

  def index
    scope = @response.projects.scoped({})
    scope = scope.scoped(:conditions => ["UPPER(name) LIKE UPPER(:q)",
                                         {:q => "%#{params[:query]}%"}]) if params[:query]
    @projects = scope.paginate(:page => params[:page], :per_page => 10,
                               :order => sort_column + " " + sort_direction) # rails 2
  end

  def new
    @project = Project.new
    respond_to do |format|
      format.html
      format.js { render :partial => 'new_inline' }
    end
  end

  def show
    @project = Project.find(params[:id])
    load_comment_resources(@project)
    respond_to do |format|
      format.html {}
      format.js {render :json => @project.to_json}
    end
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    @project = Project.new(params[:project].merge(:data_response => @response))
    create! do |success, failure|
      success.html { redirect_to response_projects_url(@response) }
      success.js do
        render :json => {:status => @project.valid?,
                         :html => render_to_string({:partial => 'workplans/project_row', 
                                              :locals => {:project => @project}})}
      end
      failure.js do
        render :json => {:status => @project.valid?, 
                         :html => render_to_string({:partial => 'new_inline', 
                                              :locals => {:project => @project}})}
      end
    end
  end

  def update
    success = FundingFlow.create_flows(params)
    update! do |success, failure|
      success.html {
        flash[:error] = "We were unable to save your funding flows, please check your data and try again" if !success
        redirect_to response_projects_url(@response)
      }
      failure.html do
        load_comment_resources(resource)
        render :action => 'edit'
      end
    end
  end

  def bulk_edit
    @projects = @response.projects
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
          saved, errors = Project.create_from_file(doc, @response)
          flash[:notice] = "Created #{saved} of #{saved + errors} projects successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to response_projects_url(@response)
    rescue
      flash[:error] = "Your CSV file does not seem to be properly formatted."
      redirect_to response_projects_path(@response)
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        if request.referrer.match('workplan')
          redirect_to response_workplans_path(@response)
        else
          redirect_to response_projects_url(@response)
        end
      end
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
      @response
    end
end
