unless ['test', 'cucumber'].include? RAILS_ENV
  load 'currencies_load_script.rb'
end