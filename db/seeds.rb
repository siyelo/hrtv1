# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

require 'yaml'
require 'fastercsv'


model_helps = open ('db/seed_files/model_help.yaml') { |f| YAML.load(f) }
def seed_model_help_from_yaml doc
  doc.each do |h|
    model_help_attribs = h.last
    #TODO replace line below, may cause trouble during deployment
    #     can replace after add rescue below
    #`touch db/seed_files/#{model_help_attribs["model_name"]}_help.yaml`
    seed_model_and_field_help model_help_attribs
  end
end

def seed_model_and_field_help  attribs
  model_help=ModelHelp.find_or_create_by_model_name attribs["model_name"]
  model_help.update_attributes attribs
  seed_field_help_from_yaml model_help
end

def seed_field_help_from_yaml model_help
  field_helps = open ("db/seed_files/#{model_help.model_name}_help.yaml") { |f| YAML.load(f) }
  if field_helps
    field_help_attribs = field_helps.map { |h| h.last }
    field_help_attribs.each do |a|
      fh = model_help.field_help.find_or_create_by_attribute_name a["attribute_name"]
      fh.update_attributes a
    end #TODO add rescue if fields file is not there
  end
end

seed_model_help_from_yaml model_helps

# seed code values
#
Code.delete_all
FasterCSV.foreach("db/seed_files/codes.csv", :headers=>true) do |row|
  c=nil #Code.first( :conditions => {:external_id =>row[:id]}) implement later
  if c.nil?
    c=Code.new
    c.external_id = row["id"]
  end
  p = Code.find_by_external_id(row["parent_id"])
  c.parent_id = p.id unless p.nil?

  c.long_display = row["description"]
  c.short_display = row["short_display"]
  c.type = row["type"].capitalize #should never be nil

  unless c.short_display
    c.short_display=row["class"]
  end

  if c.type=="NhaNasa" or c.type=="Nhanasa"
    c.type="Nha"
  end

  puts "Adding code #{c.external_id}: "
  puts "error on #{row}" unless c.save
  puts "  #{c.id}"
end

#puts 'Setting valid for next types'

#Code.all.each do |code|
#
#  puts code.id
#  other_type_children=code.children.find_all {|c|  c.class!=code.class}
#  code.valid_children_of_next_type = other_type_children
#  code.save
#  puts code.id
#  #todo add links to those of children so code to
#  #get the children when a super code is selected
#  #is easier / works at all
#end

ActivityCostCategory.delete_all
FasterCSV.foreach("db/seed_files/activity_cost_categories.csv", :headers=>true) do |row|
  c=nil #ActivityCostCategory.first( :conditions => {:id =>row[:id]}) implement update later
  unless row["include"].blank?
    if c.nil?
      c=ActivityCostCategory.new
    end
    #puts row.inspect
    %w[short_display].each do |field|
      #puts "#{field}: #{row[field]}"
      c.send "#{field}=", row[field]
    end
    puts "error on #{row}" unless c.save
  end
end

OtherCostType.delete_all
FasterCSV.foreach("db/seed_files/other_cost_types.csv", :headers=>true) do |row|
  c=nil #ActivityCostCategory.first( :conditions => {:id =>row[:id]}) implement update later
  if c.nil?
    c=OtherCostType.new
  end
  #puts row.inspect
  %w[short_display].each do |field|
    #puts "#{field}: #{row[field]}"
    c.send "#{field}=", row[field]
  end
  puts "error on #{row}" unless c.save
end

# dummy other cost rows, in future craete with callbacks on user create
def seed_other_cost_rows
  OtherCost.delete_all
  OtherCostType.all.each do |t|
    t.other_costs.create if t.other_costs.empty?
  end
end

seed_other_cost_rows

Location.delete_all
FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
  c=nil #Location.first( :conditions => {:id =>row[:id]}) implement update later
  if c.nil?
    c=Location.new
  end
  #puts row.inspect
  %w[short_display].each do |field|
    #puts "#{field}: #{row[field]}"
    c.send "#{field}=", row[field].strip
  end
  puts "error on #{row}" unless c.save
end

Organization.delete_all
FasterCSV.foreach("db/seed_files/organizations.csv", :headers=>true, :col_sep => '	') do |row|
  c=nil #Organization.first( :conditions => {:id =>row[:id]}) implement update later
  if c.nil?
    c=Organization.new
  end
 # puts row.inspect
  unless row["District"].blank?
    district = row["District"].downcase.capitalize.strip
    district = Location.find_by_short_display(district)
    if district.nil?
      puts 'nil district'
      puts row.inspect
    end
    c.locations << district
  end
  c.raw_type = row["type"].try(:strip)
  if c.raw_type == "Implementers"
    c.type = "Ngo"
  elsif c.raw_type == "Donors"
    c.type = "Donor"
  end
  #puts row.inspect
  %w[name].each do |field|
    #puts "#{field}: #{row[field]}"
    c.send "#{field}=", row[field].try(:strip)
  end
  puts "error on #{row}" unless c.save
end

%w[ self ].each do |ngo|
  Ngo.find_or_create_by_name ngo
end
