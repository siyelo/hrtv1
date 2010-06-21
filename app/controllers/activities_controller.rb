class ActivitiesController < ApplicationController
  @@shown_columns = [:projects, :name, :description,  :expected_total]
  @@create_columns = [:projects, :name, :description,  :expected_total, :target ]
  
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

  def to_label
    @s="Activity: "
    if name.nil? || name.empty?
      @s+"<No Name>"
    else
      @s+name
    end
  end
end
