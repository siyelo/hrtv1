# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

require 'yaml'

model_helps = open ('db/seed_files/model_help.yaml') { |f| YAML.load(f) }
def seed_model_help_from_yaml doc
  doc.each do |h|
    model_help_attribs = h.last
    seed_model_and_field_help model_help_attribs
  end
end

def seed_model_and_field_help  attribs 
  model_help=ModelHelp.find_or_create_by_model_name attribs["model_name"]
  model_help.update_attributes attribs
end

def seed_field_help_from_yaml model_help, field_help_attribs
  field_help_attribs.each do |a|
    fh = model_help.find_or_create_by_attribute_name field_help_attribs[:attribute_name]
    fh.update_attributes a
  end
end

seed_model_help_from_yaml model_helps
#[Project, Activity, LineItem].each { |k| create_help_for_model k }


