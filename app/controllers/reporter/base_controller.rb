class Reporter::BaseController < ApplicationController

  ### Layout
  layout 'reporter'

  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request

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
end
