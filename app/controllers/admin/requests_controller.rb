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
    create!(:notice => "Request was successfully created.") { admin_requests_url }
  end

  def update
    update!(:notice => "Request was successfully updated.") { admin_requests_url }
  end

  def destroy
    data_request = DataRequest.find(params[:id])
    data_request.destroy
    flash[:notice] = "Request was successfully deleted."
    redirect_to admin_requests_url
  end
end
