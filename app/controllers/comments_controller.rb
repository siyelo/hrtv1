class CommentsController < ApplicationController
  @@shown_columns = [:title, :comment, :commentable]
  @@create_columns = [:title, :comment]
  
  active_scaffold :comment do |config|
    config.columns =  @@shown_columns
#    list.sorting = {:created_on => 'DESC'}
  end

  def index
    @constraints = {}
    @constraints[:commentable_id] = params[:id] if params[:id]
    @constraints[:commentable_type] = params[:type] if params[:type]
  end
end
