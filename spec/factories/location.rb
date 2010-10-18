require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :location, :class => Location do |f|
  f.long_display    { Sham.location_name }
end