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
    create! do |success, failure|
      success.html do
        flash[:notice] = "Request was successfully created"
        redirect_to admin_requests_url
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Request was successfully updated"
        redirect_to admin_requests_url
      end
    end
  end

  def destroy
    data_request = DataRequest.find(params[:id])
    data_request.destroy
    flash[:notice] = "Request was successfully deleted."
    redirect_to admin_requests_url
  end
end
