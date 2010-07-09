require 'faker'
require 'factory_girl/syntax/sham'

Sham.project_name   { Faker::Name.first_name }
Sham.description    { Faker::Lorem.paragraphs((1..3).to_a.rand).join("\n") }

Factory.define :project, :class => Project do |f|
  f.name { Sham.project_name }
  f.description { Sham.description }
  f.expected_total { 20000000.00 }
end