class Admin::RequestsController < Admin::BaseController

  # Inherited Resources
  inherit_resources
  defaults :resource_class => DataRequest, 
           :collection_name => 'requests', 
           :instance_name => 'request'


  # Respond type
  respond_to :html

  def index
    @requests = DataRequest.paginate :per_page => 10, :page => params[:page],
                                          :order => 'created_at DESC'
  end

  def create
    create!(:notice => "Request was successfully created.")
  end

  def update
    update!(:notice => "Request was successfully updated.")
  end

  def destroy
    data_request = DataRequest.find(params[:id])
    if data_request.data_responses.count > 0
      flash[:error] = "You cannot delete request that has responses."
    else
      data_request.destroy
      flash[:notice] = "Request was successfully deleted."
    end
    redirect_to admin_requests_url
  end
end
