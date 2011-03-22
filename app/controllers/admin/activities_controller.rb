require 'set'
class Admin::ActivitiesController < Admin::BaseController

  ### Constants
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  ### Inherited Resources
  inherit_resources
  
  ### Helpers
  helper_method :sort_column, :sort_direction

  def index
    scope = Activity.roots.scoped({:include => :project, :joins => :project})
    scope = scope.scoped(:conditions => ["projects.name LIKE :q OR activities.name LIKE :q OR activities.description LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @activities = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def show
    @comment = Comment.new
    @comment.commentable = resource
    @comments = resource.comments.find(:all, :order => 'created_at DESC')
    show!
  end

  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "projects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
