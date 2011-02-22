Factory.define :activity, :class => Activity do |f|
  f.name            { 'activity_name' }
  f.description     { 'activity_description' }
  f.budget          { 5000000.00 }
  f.spend           { 6000000.00 }
  f.projects        { [Factory.create(:project), Factory.create(:project)] }
  f.provider        { Factory.create(:provider) }
  f.data_response   { Factory.create(:data_response) }
end

Factory.define :other_cost, :class => OtherCost, :parent => :activity do |f|
end
