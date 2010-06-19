# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
def create_help_for_model klass
  p=klass.new
  p.attribute_names.each do |n|
    Help.find_or_create_by_model_and_field klass.human_name, klass.human_attribute_name(n)
  end
end

[Project, Activity, LineItem].each { |k| create_help_for_model k }


