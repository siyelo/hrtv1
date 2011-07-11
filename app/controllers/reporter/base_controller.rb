class Reporter::BaseController < ApplicationController

  ### Layout
  layout 'reporter'

  ### Filters
  before_filter :require_user

  private
  
    def check_reporters_response
      if current_user.data_response_id_current.nil?
        flash[:notice] = "Your current response has not been set, please set it."
        redirect_to edit_organization_path(current_or_last_response) if current_user.roles.include? 'reporter'
      end
    end

    def load_data_response
      if current_user.admin?
        # work-arround until all admin actions are moved to admin controllers
        @response = DataResponse.find(params[:response_id])
      else
        @response = current_user.current_response
      end
    end

    def load_comment_resources(resource)
      @comment = Comment.new
      @comment.commentable = resource
      @comments = resource.comments.find(:all, :order => 'created_at DESC')
    end
end
