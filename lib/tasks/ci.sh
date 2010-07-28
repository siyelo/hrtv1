# A basic setup for a CI server (Hudson)
#
# You may need to do this first per CI env
#   rvm gemset create ubuzima-glennr
#   rvm gemset import ubuzima-glennr

#1

#!/bin/bash
source /var/lib/hudson/.rvm/scripts/rvm
rvm use ree-1.8.7-2010.02
rvm gemset use ubuzima-glennr
rvm gemset import ubuzima-glennr

#2
cp $WORKSPACE/config/database.yml.sample $WORKSPACE/config/database.yml
cp $WORKSPACE/config/settings.secret.example.yml $WORKSPACE/config/settings.secret.yml

#3
#!/bin/bash
source /var/lib/hudson/.rvm/scripts/rvm
rvm use ree-1.8.7-2010.02@ubuzima-glennr
export RAILS_ENV=test
rake setup_quick --trace

#4
#!/bin/bash
source /var/lib/hudson/.rvm/scripts/rvm
rvm use ree-1.8.7-2010.02@ubuzima-glennr
export RAILS_ENV=test
rake test:units

#5
#!/bin/bash
source /var/lib/hudson/.rvm/scripts/rvm
rvm use ree-1.8.7-2010.02@ubuzima-glennr
export RAILS_ENV=test
spec spec

#6
#!/bin/bash
source /var/lib/hudson/.rvm/scripts/rvm
rvm use ree-1.8.7-2010.02@ubuzima-glennr
export RAILS_ENV=cucumber
# http://blog.kabisa.nl/2010/05/24/headless-cucumbers-and-capybaras-with-selenium-and-hudson/
# and http://markgandolfo.com/2010/07/01/hudson-ci-server-running-cucumber-in-headless-mode-xvfb
export DISPLAY=:99
/etc/init.d/xvfb start
rake cucumber
RESULT=$?
/etc/init.d/xvfb stop
exit $RESULT