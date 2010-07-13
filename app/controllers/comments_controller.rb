class CommentsController < ApplicationController
  @@shown_columns = [:title, :comment, :commentable, :created_at]
  @@create_columns = [:title, :comment]

  active_scaffold :comment do |config|
    config.create.persistent = false
    config.columns =  @@shown_columns
    config.columns[:commentable].label = "Comment On"
    list.sorting = {:created_at => 'DESC'}
  end

end
