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
    destroy!(:notice => "Request was successfully deleted.")
  end
end
