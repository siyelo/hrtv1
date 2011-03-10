Factory.define :activity, :class => Activity do |f|
  f.sequence(:name) { |i| "activity_name_#{i}" }
  f.description     { 'activity_description' }
  f.budget          { 5000000.00 }
  f.spend           { 6000000.00 }
  f.project         { Factory.create(:project) }
  f.provider        { Factory.create(:provider) }
  f.data_response   { Factory.create(:data_response) }
  f.start_date      { Date.parse("2010-01-01") }
  f.end_date        { Date.parse("2010-12-31") }
end

Factory.define :other_cost, :class => OtherCost, :parent => :activity do |f|
end

Factory.define :sub_activity, :class => SubActivity, :parent => :activity do |f|
  f.sequence(:name) { |i| "sub_activity_name_#{i}" }
  f.description     { 'sub_activity_description' }
  f.activity        { Factory.create :activity }
end
