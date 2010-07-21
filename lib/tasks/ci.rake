desc "cijoe runner command"
task :ci => [ "rake -s setup:all", "rake -s test:units"]
