Factory.define :commodity, :class => Commodity do |f|
  f.commodity_type      { 'Vehicles' }
  f.description         { 'project_description' }
  f.unit_cost           { 200.00 }
  f.quantity            { 5 }
  f.data_response       { Factory(:data_response) }
end
