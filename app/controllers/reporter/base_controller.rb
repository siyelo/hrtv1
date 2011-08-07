class Reporter::BaseController < ApplicationController
  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request


  private
    def js_redirect
      render :json => {:html => render_to_string(:partial => 'activities/bulk_edit',
                                       :layout => false,
                                       :locals => {:activity => @activity,
                                                   :response => @response})}
    end
end
