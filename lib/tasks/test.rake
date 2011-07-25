desc "Test app with Cuke & RSpec"
puts "Depricated, don't use this as it doesn't use database cleaner so all specs involving currencies will fail"  #fix this to use database cleaner
task :test => [ "spec", "cucumber" ]