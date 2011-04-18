Factory.define :data_response, :class => DataResponse do |f|
  f.data_request             { Factory(:data_request) }
  f.organization             { Factory(:organization) }
  f.currency                 { "RWF" }
  f.fiscal_year_start_date   { Date.parse("2010-01-01") }
  f.fiscal_year_end_date     { Date.parse("2010-12-31") }
  f.contact_name             { "Bob" }
  f.contact_position         { "Manager" }
  f.contact_phone_number     { "123123123" }
  f.contact_main_office_phone_number {"234234234"}
  f.contact_office_location  { "Cape Town" }
end
