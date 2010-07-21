# A basic setup for a CI server
#
# this script assumes its run from the RAILS_ROOT dir
#
# to configure your CI Joe server, add this
#   $ git config --add cijoe.runner "ruby lib/tasks/ci.rb"
#
EXIT_OK = 0
EXIT_NOK = 1

# copy in any yamls not in the repo
system "cp config/database.yml.sample config/database.yml"
system "cp config/settings.secret.example.yml config/settings.secret.yml"

#run db creation and seeding
seeded = system "rake -s setup"
exit EXIT_NOK unless seeded == EXIT_OK

# cijoe build
built = system "rake -s test"
exit EXIT_NOK unless built == EXIT_OK

return result