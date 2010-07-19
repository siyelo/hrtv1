desc "Test app with Cuke & RSpec"
task :test => [ "test:units", "spec", "cucumber" ]