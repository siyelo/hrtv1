require 'faker'
require 'factory_girl/syntax/sham'

Sham.project_name   { Faker::Name.first_name }
Sham.description    { Faker::Lorem.paragraphs((1..3).to_a.rand).join("\n") }
Sham.sentence       { Faker::Lorem.sentence }

Sham.activity_name  { Faker::Name.first_name }
Sham.username       { "user_" + Faker::Internet.user_name }
Sham.email          { Faker::Internet.email }
Sham.organization_name  { Faker::Company.name }

Sham.location_name  { Faker::Name.first_name } #we just need a string
Sham.app_model_name { ['Code', 'OtherCost', 'Project', 'Activity'].rand }

Sham.cents          { ((0..99).to_a.rand.to_f / 100) }
Sham.budget         {  rand(1000000) + Sham.cents }

Sham.amount         {  rand(100) + Sham.cents }
Sham.code_name      { Faker::Name.first_name }

