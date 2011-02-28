class Admin::DataRequestsController < Admin::BaseController

  # Inherited Resources
  inherit_resources

  # Respond type
  respond_to :html

  def index
    @data_requests = DataRequest.paginate :per_page => 10, :page => params[:page],
                                          :order => 'created_at DESC'
  end

  def create
    create!(:notice => "Data request was successfully created.")
  end

  def update
    update!(:notice => "Data request was successfully updated.")
  end

  def destroy
    destroy!(:notice => "Data request was successfully deleted.")
  end
end
