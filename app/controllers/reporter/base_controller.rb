class Reporter::BaseController < ApplicationController
  layout 'reporter'
  before_filter :require_user
end