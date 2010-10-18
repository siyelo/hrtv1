require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :model_help, :class => ModelHelp do |f|
  f.model_name  { Sham.app_model_name }
  f.short       { Sham.sentence }
  f.long        { Sham.description }
end
