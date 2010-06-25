class ActivitiesController < ApplicationController
  @@shown_columns = [:projects, :name, :description,  :expected_total]
  @@create_columns = [:projects, :name, :description,  :expected_total, :target ]
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s} # TODO fix bug, projects for instance won't work

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :activity do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}
    config.nested.add_link("Line Items", [:lineItems])

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:projects].inplace_edit = true
    config.columns[:projects].form_ui = :select
    config.columns[:name].inplace_edit = true
    config.columns[:description].inplace_edit = true
    config.columns[:description].form_ui = :textarea
    config.columns[:expected_total].inplace_edit = true
    config.columns[:target].label = "Target Population"

    # add in later version, not part of minimal viable product
    #config.columns[:indicators].form_ui = :select
    #config.columns[:indicators].options = {:draggable_lists => true}
  end

  def index

  end

  def create_from_file
    super @@columns_for_file_upload
  end

  def to_label
    @s="Activity: "
    if name.nil? || name.empty?
      @s+"<No Name>"
    else
      @s+name
    end
  end
end
