# A basic setup for a CI server
#
# this script assumes its run from the RAILS_ROOT dir
#
# to configure your CI Joe server, add this
#   $ git config --add cijoe.runner "ruby lib/tasks/ci.rb"
#

# copy in any yamls not in the repo
system "cp config/database.yml.sample config/database.yml"
system "cp config/settings.secret.example.yml config/settings.secret.yml"

# cijoe build
system "rake -s test:units"