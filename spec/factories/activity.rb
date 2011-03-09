Factory.define :activity, :class => Activity do |f|
  f.name            { 'activity_name' }
  f.description     { 'activity_description' }
  f.budget          { 5000000.00 }
  f.spend           { 6000000.00 }
  f.projects        { [Factory.create(:project), Factory.create(:project)] }
  f.provider        { Factory.create(:provider) }
  f.data_response   { Factory.create(:data_response) }
  f.start_date      { Date.parse("2010-01-01") }
  f.end_date        { Date.parse("2010-12-31") }
end

Factory.define :other_cost, :class => OtherCost, :parent => :activity do |f|
end

Factory.define :sub_activity, :class => SubActivity do |f|
  f.name            { 'sub_activity_name' }
  f.description     { 'sub_activity_description' }
  f.budget          { 5000000.00 }
  f.activity        { Factory.create :activity }
  f.data_response   { Factory.create(:data_response) }
  f.start_date      { Date.parse("2010-01-01") }
  f.end_date        { Date.parse("2010-12-31") }
end
