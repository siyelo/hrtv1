class CommentsController < Reporter::BaseController

  def index
    if current_user.admin?
      @comments = Comment.paginate :per_page => 20, :page => params[:page], :order => 'created_at DESC'
    else
      @comments = Comment.on_all(current_user.organization).paginate :per_page => 20, :page => params[:page], :order => 'created_at DESC'
    end

    render :layout => 'admin'
  end

  def new
    @comment = Comment.new
    @comment.commentable = find_commentable
    load_data_response(@comment)

    respond_to do |format|
      format.html
      format.js { render :partial => "form", :locals => {:comment => @comment} }
    end
  end

  def show
    @comment = find_comment
    load_data_response(@comment)

    respond_to do |format|
      format.html
      format.js { render :partial => 'row', :locals => {:comment => @comment} }
      format.json { render :json => @comment}
    end
  end

  def edit
    @comment = current_user.admin? ? Comment.find(params[:id]) : Comment.on_all(current_user.organization).find(params[:id])
    load_data_response(@comment)

    respond_to do |format|
      format.html
      format.js { render :partial => "form", :locals => {:comment => @comment } }
    end
  end

  def create
    @comment = current_user.comments.new(params[:comment])
    @comment.commentable = find_commentable
    load_data_response(@comment)
    if @comment.save
      @comment.email_the_organisation_users(@comment) if current_user.admin?
      respond_to do |format|
        format.html do
          flash[:notice] = "Comment was successfully created."
          redirect_to :back ##sorry
          # redirect_to commentable_resource(@comment)
        end
        format.js { render :partial => "row", :locals => {:comment => @comment} }
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = "You cannot create blank comment."
          redirect_to :back #sorry
          # redirect_to commentable_resource(@comment)
        end
        format.js  { render :partial => "form",
                     :locals => {:comment => @comment},
                     :status => :partial_content } # :partial_content => 206
      end
    end
  end

  def update
    @comment = find_comment
    load_data_response(@comment)

    if @comment.update_attributes(params[:comment])
      respond_to do |format|
        format.html do
          flash[:notice] = "Comment was successfully updated."
          redirect_to commentable_resource(@comment)
        end
        format.js { render :partial => "row", :locals => {:comment => @comment } }
        format.json { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.js { render :partial => "form", :locals => {:comment => @comment}, :status => :partial_content } # :partial_content => 206
        format.json { render :nothing => true }
      end
    end
  end

  def destroy
    @comment = find_comment
    @comment.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Comment was successfully deleted."
        redirect_to comments_url
      end
      format.js { render :nothing => true }
    end

  end

  def delete
    @comment = find_comment
    load_data_response(@comment)
  end

  protected
    def find_commentable
      klass = params[:commentable_type].constantize
      klass.find(params[:commentable_id])
    end

    def find_comment
      current_user.admin? ? Comment.find(params[:id]) : Comment.on_all(current_user.organization).find(params[:id], :readonly => false)
    end

    def commentable_resource(comment)
      if comment.commentable_type == "Activity"
        if current_user.admin?
          admin_activity_url(comment.commentable)
        else
          if comment.commentable.is_a?(OtherCost)
            edit_response_other_cost_url(comment.commentable.data_response, comment.commentable)
          else
            edit_response_activity_url(comment.commentable.data_response, comment.commentable)
          end
        end
      elsif comment.commentable_type == "Project"
        if current_user.admin?
          response_project_url(comment.commentable.data_response, comment.commentable)
        else
          edit_response_project_url(comment.commentable.data_response, comment.commentable)
        end
      else
        comments_url
      end
    end

    def load_data_response(comment)
      if comment.commentable.is_a?(DataResponse)
        @response = comment.commentable
      else
        @response = comment.commentable.data_response
      end
    end
end
