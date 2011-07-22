class Reporter::BaseController < ApplicationController
  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request
end
