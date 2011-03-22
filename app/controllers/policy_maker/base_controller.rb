class PolicyMaker::BaseController < ApplicationController

  ### Layout
  layout 'admin'

  ### Filters
  before_filter :require_admin
end
