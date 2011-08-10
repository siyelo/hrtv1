class OtherCostsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['description', 'past expenditure', 'current budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_response
  before_filter :confirm_activity_type, :only => [:edit]
  belongs_to :data_response, :route_name => 'response', :instance_name => 'response'

  def index
    scope = @response.other_costs.scoped({})
    scope = scope.scoped(:conditions => ["UPPER(activities.name) LIKE UPPER(:q) OR
                                         UPPER(activities.description) LIKE UPPER(:q)",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @other_costs = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def new
    @other_cost = OtherCost.new
    @other_cost.project = @response.projects.find_by_id(params[:project_id]) if params[:project_id]
    @other_cost.data_response = @response
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    if params[:other_cost][:project_id] == "-1" then
      create_project
    end
    
    @other_cost = @response.other_costs.new(params[:other_cost])
    @other_cost.data_response = @response

    if @other_cost.save
      respond_to do |format|
        format.html do
          flash[:notice] = 'Other Cost was successfully created'
          html_redirect
        end
        format.js { js_redirect }
      end
    else
      respond_to do |format|
        format.html { render :action => :new }
        format.js { js_redirect }
      end
    end
  end

  def update
    @activity = resource # needed in js_redirect
    if params[:other_cost][:project_id] == "-1" then
      create_project
    end
    
    update! do |success, failure|
      success.html { flash[:notice] = 'Other Cost was successfully updated'; html_redirect }
      success.js   { js_redirect }
      failure.html { load_comment_resources(resource); render :action => 'edit'}
      failure.js   { js_redirect }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        flash[:notice] = 'Other Cost was successfully destroyed'
        redirect_to response_projects_url(@response)
      end
    end
  end

  def download_template
    template = OtherCost.download_template
    send_csv(template, 'other_costs_template.csv')
  end

  def create_from_file
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        if doc.headers.to_set == OtherCost::FILE_UPLOAD_COLUMNS.to_set
          saved, errors = OtherCost.create_from_file(doc, @response)
          flash[:notice] = "Created #{saved} of #{saved + errors} other costs successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to response_other_costs_url(@response)
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to response_other_costs_url(@response)
    end
  end


  private
    
    def create_project
      @project =  @response.projects.find_by_name(params[:other_cost][:name])
      unless @project
        @project = Project.new(:name       => params[:other_cost][:name], 
                               :start_date => params[:other_cost][:start_date], 
                               :end_date   => params[:other_cost][:end_date], 
                               :data_response => @response)
      end
      @project.save ? params[:other_cost][:project_id] = @project.id : params[:other_cost][:project_id] = ""
    end
  
    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "activities.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def html_redirect
      if params[:commit] == "Save & Classify >"
        redirect_to edit_activity_classification_path(@other_cost, 'purposes')
      else
        redirect_to edit_response_other_cost_path(@response, @other_cost)
      end
    end


    def confirm_activity_type
      @activity = Activity.find(params[:id])
      return redirect_to edit_response_activity_path(@response, @activity) if @activity.class.eql? Activity
      return redirect_to edit_response_activity_path(@response, @activity.activity) if @activity.class.eql? SubActivity
    end

end
