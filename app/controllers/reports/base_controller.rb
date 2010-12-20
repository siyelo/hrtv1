class Reports::BaseController < ApplicationController
  layout 'admin'
  before_filter :require_user
end
