Factory.define :project, :class => Project do |f|
  f.sequence(:name)     { |i| "project_name_#{i}_#{rand(100_000_000)}" }
  f.description         { 'project_description' }
  f.start_date          { "2010-01-01" }
  f.end_date            { "2010-12-31" }
end