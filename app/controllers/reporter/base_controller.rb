class Reporter::BaseController < ApplicationController

  ### Layout
  layout 'reporter'

  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request

  protected

    def change_user_current_response(new_response_id)
      user = current_user
      response = user.responses.find(new_response_id)
      if response
        user.data_response_id_current = response.id
        if user.save
          user.reload #otherwise current_response association is stale
          request = user.current_response.request
          if user.current_response_is_latest?
            flash[:notice] = "You are now viewing your data for the latest Request: \"<span class='bold'>#{request.name}</span>\""
          end
        else
          flash[:error] = "Sorry we could not update your response"
        end
      else
        flash[:error] = "Sorry we could not find that response"
      end
    end

    def not_latest_request_message(request)
      "You are now viewing your data for the Request: \"<span class='bold'>#{request.name}</span>\".
       All changes made will be saved for this Request.
       Would you like to <a href='#{set_latest_responses_path}'>resume editing the latest Request?</a>"
    end

  private

    def load_data_response
      if current_user.admin?
        # work-arround until all admin actions are moved to admin controllers
        @response = DataResponse.find(params[:response_id])
      elsif current_user.activity_manager?
        # scope by the organizations the AM has access to
        @response = DataResponse.find(params[:response_id],
          :conditions => ["organization_id in (?)", [current_user.organization.id] + current_user.organizations.map{|o| o.id}])
      else
        @response = current_user.data_responses.find(params[:response_id])
      end
    end

    def load_comment_resources(resource)
      @comment = Comment.new
      @comment.commentable = resource
      @comments = resource.comments.find(:all, :order => 'created_at DESC',
                                         :conditions => 'parent_id is NULL',
                                         :include => :user)
      # @comments = resource.comments.roots.find(:all)
      # :include => {:user => :organization} does not work when using roots scope
      # Comment.send(:preload_associations, @comments, {:user => :organization})
    end

    def warn_if_not_current_request
      unless current_user.current_response_is_latest?
        flash.now[:warning] = not_latest_request_message(current_user.current_request)
      end
    end

end
