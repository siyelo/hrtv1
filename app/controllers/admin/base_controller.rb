class Admin::BaseController < ApplicationController
  ### Filters
  before_filter :require_admin
  before_filter :warn_if_not_current_request
end
