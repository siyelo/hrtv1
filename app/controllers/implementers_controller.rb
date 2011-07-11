class ImplementersController < Reporter::BaseController
  before_filter :load_data_response
  before_filter :load_projects

  def index
  end

  def new
    @implementer = SubActivity.new
    @implementer.data_response = @response
    @implementer.activity = @response.activities.find_by_id(params[:activity_id])

    respond_to do |format|
      format.json do
        render :json => {:html => render_to_string({:partial => 'new_inline.html.haml'})}
      end
    end
  end

  def create
    @activity = @response.activities.find(params[:sub_activity].delete(:activity_id))
    @implementer = @activity.sub_activities.new(params[:sub_activity])

    if @implementer.save
      respond_to do |format|
        format.json do
          render :json => {:status => @implementer.valid?,
            :html => render_to_string({:partial => 'implementer_row.html.haml',
                                       :locals => {:implementer => @implementer,
                                         :type => params[:type]}})}
        end
      end
    else
      respond_to do |format|
        format.json do
          render :json => {:status => @implementer.valid?,
                           :html => render_to_string({:partial => 'new_inline.html.haml'})}
        end
      end
    end
  end

  def update
    if params[:sub_activities]
      SubActivity.bulk_update(@response, params[:sub_activities])
      flash[:notice] = 'Implementers were successfully saved'
    end
    
    if params[:commit] == "Save"
      redirect_to response_implementers_url(@response)
    else
      if @response.request.purposes?
        redirect_to edit_response_classification_path(@response, 'CodingSpend')
      # elsif @response.request.locations?
        # Add redirect to locations tab once locations have been re-enabled 
      else
        redirect_to response_long_term_budgets_path
      end  
    end
  end
  
  def destroy
    implementer = current_response.activities.find(params[:id])
    implementer.destroy
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
