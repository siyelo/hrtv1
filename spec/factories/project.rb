Factory.define :project, :class => Project do |f|
  f.sequence(:name)     { |i| "project_name_#{i}_#{rand(100_000_000)}" }
  f.description         { 'project_description' }
  f.budget              { 90.00 }
  f.spend               { 100.00 }
  f.start_date          { "2010-01-01" }
  f.end_date            { "2010-12-31" }
  f.data_response       { Factory.create(:response) }
end

Factory.define :complete_project, :parent => :project do |f|
  f.after_create { |p| Factory(:funding_flow, :to => p.organization, :project => p,
    :data_response => p.response) }
end
