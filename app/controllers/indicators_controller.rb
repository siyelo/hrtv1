class IndicatorsController < ApplicationController
  @@shown_columns = [:name, :description]
  @@create_columns = [:name, :description]
  
  active_scaffold :indicator do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}
    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:name].inplace_edit = true
    config.columns[:description].inplace_edit = true
    config.columns[:description].form_ui = :textarea
  end
  
  def to_label
    @s="Indicator: "
    if name.nil? || name.empty?
      @s+"<No Name>"
    else
      @s+name
    end
  end
end
