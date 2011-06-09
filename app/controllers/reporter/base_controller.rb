class Reporter::BaseController < ApplicationController
  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request

  private

    def load_comment_resources(resource)
      @comment = Comment.new
      @comment.commentable = resource
      @comments = resource.comments.find(:all, :order => 'created_at DESC')
    end
end
