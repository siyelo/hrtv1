class PolicyMaker::BaseController < ApplicationController
  ### Filters
  before_filter :require_admin
end
