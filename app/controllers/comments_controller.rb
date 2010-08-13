class CommentsController < ApplicationController

  authorize_resource

# TODO use the named cscopes from cancan in beginning of cahin
  #  to do proper scoping here by type and data_response of commentable
# TODO check that beginning_chain limits the commentables you can find
  # from the other things

  @@shown_columns = [:title, :comment, :commentable, :created_at]
  @@create_columns = [:title, :comment]

  active_scaffold :comment do |config|
    config.create.persistent = false
    config.columns =  @@shown_columns
    config.columns[:commentable].label = "Comment On"
    list.sorting = {:created_at => 'DESC'}
  end

end
