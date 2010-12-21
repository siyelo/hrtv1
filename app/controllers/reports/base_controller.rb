class Reports::BaseController < ApplicationController
  layout 'reports'
  before_filter :require_user
end
