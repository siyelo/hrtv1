class OtherCostsController < ApplicationController
  @@shown_columns = [:projects, :description,  :fields]
  @@create_columns = [:projects, :provider, :name, :description,  :expected_total, :target ]
end
