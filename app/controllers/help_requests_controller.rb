class HelpRequestsController < ActiveScaffoldController

  authorize_resource
  @@shown_columns = [:email, :message, :created_at]

  active_scaffold :help_request do |config|
    config.label = "Help Requests"
    config.create.persistent = false
    config.columns =  @@shown_columns
    list.sorting = {:created_at => 'DESC'}
    #TODO remove the create action here so
    # admins don't try to create
  end
end
