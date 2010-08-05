
puts "  Loading model helps..."
require 'yaml'

model_helps = open ('db/seed_files/model_help.yaml') { |f| YAML.load(f) }
def seed_model_help_from_yaml doc
  doc.each do |h|
    model_help_attribs = h.last
    #TODO replace line below, may cause trouble during deployment
    #     can replace after add rescue below
    `touch db/seed_files/#{model_help_attribs["model_name"]}_help.yaml`
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