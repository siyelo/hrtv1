class Admin::CommentsController < Admin::BaseController

  ### Inherited Resources
  inherit_resources

  def index
    @comments = Comment.paginate :per_page => 20, :page => params[:page],
                                 :order => 'created_at DESC'
  end

  def update
    update! do |format|
      format.html { redirect_to admin_comments_url }
    end
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to admin_comments_url }
    end
  end
end
