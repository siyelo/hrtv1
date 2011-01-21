Factory.define :data_response, :class => DataResponse do |f|
  f.data_request             { Factory.create(:data_request) }
  f.responding_organization  { Factory.create(:organization) }
  f.fiscal_year_start_date   { Date.parse("2010-01-01") }
  f.fiscal_year_end_date     { Date.parse("2010-12-31") }
end
