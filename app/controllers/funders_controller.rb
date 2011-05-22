class FundersController < Reporter::BaseController
  before_filter :load_data_response
  before_filter :load_projects

  def new
    @funder = FundingFlow.new
    @funder.project = @response.projects.find_by_id(params[:project_id])
    render :partial => 'new_inline', :layout => false
  end

  def edit
  end

  def create
    @funder = @response.funding_flows.new(params[:funding_flow])

    if @funder.save
      render :json => {:status => @funder.valid?,
                       :html => render_to_string({:partial => 'funder_row.html.haml',
                                            :locals => {:funder => @funder,
                                                        :type => params[:type]}})}
    else
      render :json => {:status => @funder.valid?,
                       :html => render_to_string({:partial => 'new_inline.html.haml'})}
    end
  end

  def update
    FundingFlow.bulk_update(@response, params[:funders])
    flash[:notice] = 'Funders were successfully saved'
    redirect_to edit_response_funder_url(@response, params[:id])
  end

  private
    def load_projects
      @projects = @response.projects.find(:all, :order => "id ASC")
    end
end
