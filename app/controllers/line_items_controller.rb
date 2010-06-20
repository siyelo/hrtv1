class LineItemsController < ApplicationController
  @@shown_columns = [:amount]
  @@create_columns = @@shown_columns
  
  active_scaffold :line_items do |config|
    config.columns =  @@shown_columns
    list.sorting = {:amount => 'DESC'}

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
  end

  def index
  end
end
