# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

require 'yaml'

#model_help = open ('db/seed_files/model_help.yaml') { |f| YAML.load(f) }
def populate_from_yaml klass
  p=klass.new
  p.attribute_names.each do |n|
    ModelHelp.find_or_create_by_model_and_field klass.human_name, klass.human_attribute_name(n)
  end
end

#[Project, Activity, LineItem].each { |k| create_help_for_model k }


