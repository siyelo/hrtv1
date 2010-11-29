class Admin::DashboardController < Admin::BaseController

  def index
    @comments = Comment.find(:all, :order => 'created_at DESC', :limit => 5)
  end
end
