require 'faker'
require 'factory_girl/syntax/sham'

Sham.project_name   { Faker::Name.first_name }
Sham.description    { Faker::Lorem.paragraphs((1..3).to_a.rand).join("\n") }

Sham.activity_name  { Faker::Name.first_name }
Sham.username       { Faker::Internet.user_name }
Sham.email          { Faker::Internet.email }
Sham.organization_name  { Faker::Company.name }

Sham.cents   { ((0..99).to_a.rand.to_f / 100) }
Sham.budget  {  rand(1000000) + Sham.cents }
