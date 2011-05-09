# A basic setup for a CI server (Hudson)
#
# You may need to do this first per CI env
#   rvm gemset create hrt
#   rvm gemset import hrt

#!/bin/bash
cp .rvmrc_ree .rvmrc
source /var/lib/jenkins/.rvm/scripts/rvm
rvm use ree-1.8.7-2011.03@hrt
bundle install


cp $WORKSPACE/config/database.yml.sample.sqlite3 $WORKSPACE/config/database.yml



#!/bin/bash
cp .rvmrc_ree .rvmrc
source /var/lib/jenkins/.rvm/scripts/rvm
rvm use ree-1.8.7-2011.03@hrt
export RAILS_ENV=test
rake setup_quick --trace



#!/bin/bash
source /var/lib/jenkins/.rvm/scripts/rvm
rvm use ree-1.8.7-2011.03@hrt
export RAILS_ENV=test
spec spec



#!/bin/bash
source /var/lib/jenkins/.rvm/scripts/rvm
rvm use ree-1.8.7-2011.03@hrt
export RAILS_ENV=cucumber
# http://blog.kabisa.nl/2010/05/24/headless-cucumbers-and-capybaras-with-selenium-and-hudson/
# and http://markgandolfo.com/2010/07/01/hudson-ci-server-running-cucumber-in-headless-mode-xvfb
export DISPLAY=:99
/etc/init.d/xvfb start
rake cucumber
RESULT=$?
/etc/init.d/xvfb stop
exit $RESULT