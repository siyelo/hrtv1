desc "cijoe runner command"
task :ci => [ "setup:all", "test:units"]
