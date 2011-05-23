class FundersController < Reporter::BaseController
  before_filter :load_data_response
  before_filter :load_projects

  def new
    @funder = FundingFlow.new
    @funder.project = @response.projects.find_by_id(params[:project_id])

    respond_to do |format|
      format.json do
        render :json => {:html => render_to_string({:partial => 'new_inline.html.haml'})}
      end
    end
  end

  def edit
  end

  def create
    check_for_new_funder(params)
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
    FundingFlow.bulk_update(@response, params[:funders])
    flash[:notice] = 'Funders were successfully saved'
    redirect_to edit_response_funder_url(@response, params[:id])
  end

  private
    def load_projects
      @projects = @response.projects.find(:all, :order => "id ASC")
    end

    def check_for_new_funder(params)
      if !params[:funding_flow].nil? && !params[:funding_flow][:organization_id_from].nil?
        id_or_name = params[:funding_flow][:organization_id_from]
        unless is_number?(id_or_name)
          org  = Organization.find_or_create_by_name(id_or_name)
          params[:funding_flow][:organization_id_from] = org.id
        end
      end
    end
end
