require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :code, :class => Code do |f|
  f.short_display   { Sham.code_name }
  f.description     { Sham.description }
end

Factory.define :mtef_code, :class => Mtef, :parent => :code do |f|
end

