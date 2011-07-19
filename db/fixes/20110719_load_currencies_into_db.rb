require 'yaml'
file = YAML.load_file "#{RAILS_ROOT}/config/currencies.yml"
puts "Importing currencies to the database\n"
file.each { |currency| 
            Currency.create!(:conversion => currency[0], 
                             :rate => currency[1])
}
puts "Finished importing currencies to the database\n"