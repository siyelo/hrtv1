class FundersController < Reporter::BaseController
  before_filter :load_data_response
  before_filter :load_projects

  def index
  end

  def new
    @funder = FundingFlow.new
    @funder.project = @response.projects.find_by_id(params[:project_id])

    respond_to do |format|
      format.json do
        render :json => {:html => render_to_string({:partial => 'new_inline.html.haml'})}
      end
    end
  end

  def create
    check_for_new_organization(params[:funding_flow], :organization_id_from)
    @funder = @response.funding_flows.new(params[:funding_flow])

    if @funder.save
      respond_to do |format|
        format.json do
          render :json => {:status => @funder.valid?,
                           :html => render_to_string({:partial => 'funder_row.html.haml',
                                                :locals => {:funder => @funder,
                                                            :type => params[:type]}})}
        end
      end
    else
      respond_to do |format|
        format.json do
          render :json => {:status => @funder.valid?,
                           :html => render_to_string({:partial => 'new_inline.html.haml'})}
        end
      end
    end
  end

  def update
    if params[:funders]
      FundingFlow.bulk_update(@response, params[:funders])
      flash[:notice] = 'Funders were successfully saved'
    end
    
    if params[:commit] == "Save"
      redirect_to response_funders_url(@response)
    else
      redirect_to response_implementers_path(@response)
    end  
  end
  
  def destroy
    funder = current_response.funding_flows.find(params[:id])
    funder.destroy
    respond_to do |format|
      format.json do
        render :json => {:status => 'success'}
      end
    end
  end

  private
    def load_projects
      @projects = @response.projects.find(:all, :order => "id ASC")
    end
end
