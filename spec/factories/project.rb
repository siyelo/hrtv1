Factory.define :project, :class => Project do |f|
  f.sequence(:name)     { |i| "project_name_#{i}" }
  f.description         { 'project_description' }
  f.budget              { 90.00 }
  f.spend               { 100.00 }
  f.start_date          { Date.parse("2010-01-01") }
  f.end_date            { Date.parse("2010-12-31") }
  f.am_approved         { false }
  f.data_response       { Factory(:data_response) }
end

Factory.define :complete_project, :parent => :project do |f|
  f.after_create { |p| Factory(:funding_flow, :to => p.organization, :project => p,
    :data_response => p.response) }
end
