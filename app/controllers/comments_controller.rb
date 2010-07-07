class CommentsController < ApplicationController
  @@shown_columns = [:title, :comment, :commentable]
  @@create_columns = [:title, :comment]

  active_scaffold :comment do |config|
    config.columns =  @@shown_columns
#    list.sorting = {:created_on => 'DESC'}
  end

end