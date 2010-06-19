class ActivitiesController < ApplicationController
  @@shown_columns = [:name, :description,  :expected_total]
  @@create_columns = [:name, :description,  :expected_total,  :indicators, :target ]
  
  active_scaffold :activity do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}
    config.nested.add_link("Line Items", [:lineItems])
    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:name].inplace_edit = true
    config.columns[:description].inplace_edit = true
    config.columns[:description].form_ui = :textarea
    config.columns[:expected_total].inplace_edit = true
    config.columns[:target].label = "Target Population"
    
    config.columns[:indicators].form_ui = :select
    config.columns[:indicators].options = {:draggable_lists => true}
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
