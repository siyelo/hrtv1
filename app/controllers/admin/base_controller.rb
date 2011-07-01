class Admin::BaseController < ApplicationController

  ### Layout
  layout 'admin'

  ### Filters
  before_filter :require_admin
  before_filter :warn_if_not_current_request

end
