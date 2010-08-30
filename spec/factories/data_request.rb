require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :data_request, :class => DataRequest do |f|
  f.title      { 'some title' }
  f.requesting_organization  { Factory.create(:organization) }
end