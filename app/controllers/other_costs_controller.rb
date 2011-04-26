class OtherCostsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response', :instance_name => 'response'

  def index
    scope = @response.other_costs.scoped()
    scope = scope.scoped(:conditions => ["UPPER(activities.name) LIKE UPPER(:q) OR
                                         UPPER(activities.description) LIKE UPPER(:q)",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @other_costs = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def show
    load_comment_resources(resource)
    show!
  end
  
  def create
    create! do |success, failure|
      success.html { 
        valid = @other_cost.check_projects_budget_and_spend?
        if params[:commit] == "Save & Go to Classify >"
          if valid
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingSpend') if @response.data_request.spend?
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingBudget') if @response.data_request.budget?
          else
            flash.delete(:notice)
            flash[:error] = "Please be aware that your activities spend/budget exceeded that of your projects"
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingSpend') if @response.data_request.spend?
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingBudget') if @response.data_request.budget?
          end
        else
          flash.delete(:notice) unless valid
          flash[:error] = "Please be aware that your activities spend/budget exceeded that of your projects" unless valid
          redirect_to response_projects_path(@other_cost.project.response)
        end
      }
    end
  end
  
  
  def update
    update! do |success, failure|
      success.html { 
        valid = @other_cost.check_projects_budget_and_spend?
        if params[:commit] == "Save & Go to Classify >"
          if valid
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingSpend') if @response.data_request.spend?
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingBudget') if @response.data_request.budget?
          else
            flash.delete(:notice)
            flash[:error] = "Please be aware that your activities spend/budget exceeded that of your projects"
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingSpend') if @response.data_request.spend?
            return redirect_to activity_code_assignments_path(@other_cost, :coding_type => 'CodingBudget') if @response.data_request.budget?
          end
        else
          flash[:error] = "Please be aware that your activities spend/budget exceeded that of your projects" unless valid
          flash.delete(:notice) unless valid
          redirect_to response_projects_path(@other_cost.project.response)
        end
      }
      failure.html do
        load_comment_resources(resource)
        render :action => 'edit'
      end
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
      flash[:error] = "Your CSV file does not seem to be properly formatted."
      redirect_to response_other_costs_url(@response)
    end
  end


  private
    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "activities.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
