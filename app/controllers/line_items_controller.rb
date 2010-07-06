class LineItemsController < ApplicationController
  @@shown_columns = [:amount]
  @@create_columns = @@shown_columns
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s}
  
  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

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
  
  def create_from_file
    super @@columns_for_file_upload
  end
end
