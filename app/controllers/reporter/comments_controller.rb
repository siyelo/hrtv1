# TODO: move this to /app/controller/comments_controller.rb
# when AS gets removed
class Reporter::CommentsController < Reporter::BaseController

  def new
    @comment = Comment.new
    @comment.commentable = find_commentable

    respond_to do |format|
      format.html
      format.js { render :partial => "form", :locals => {:comment => @comment} }
    end
  end

  def show
    @comment = find_comment

    respond_to do |format|
      format.html
      format.js { render :partial => 'row', :locals => {:comment => @comment} }
      format.json { render :json => @comment}
    end
  end

  def edit
    @comment = current_user.role?(:admin) ? Comment.find(params[:id]) : current_user.comments.find(params[:id])

    respond_to do |format|
      format.html
      format.js { render :partial => "form", :locals => {:comment => @comment } }
    end
  end

  def create
    @comment = current_user.comments.new(params[:comment])
    @comment.commentable = find_commentable

    if @comment.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Comment was successfully created."
          redirect_to commentable_resource(@comment)
        end
        format.js { render :partial => "row", :locals => {:comment => @comment} }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.js { render :partial => "form", :locals => {:comment => @comment}, :status => :partial_content } # :partial_content => 206
      end
    end
  end

  def update
    @comment = find_comment

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
  end

  protected
  def find_commentable
    klass = params[:commentable_type].constantize
    klass.find(params[:commentable_id])
  end

  def find_comment
    current_user.role?(:admin) ? Comment.find(params[:id]) : Comment.on_all(current_user.organization).find(params[:id], :readonly => false)
  end

  def commentable_resource(comment)
    if comment.commentable_type == "Activity"
      response_activity_url(comment.commentable.data_response, comment.commentable)
    elsif comment.commentable_type == "Project"
      response_project_url(comment.commentable.data_response, comment.commentable)
    else
      comments_url
    end
  end
end
