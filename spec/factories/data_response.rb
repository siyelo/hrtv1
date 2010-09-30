require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :data_response, :class => DataResponse do |f|
  f.responding_organization  { Factory.create(:organization) }
  f.currency                 { 'USD' }
  f.fiscal_year_start_date   { DateTime.new(2010, 01, 01) }
  f.fiscal_year_end_date     { DateTime.new(2010, 12, 31) }
end
