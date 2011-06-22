## For Developers

* Google Group: http://groups.google.com/group/rwandaonrails

* Pivotal Tracker: http://www.pivotaltracker.com/projects/59773

  * Its public - so click the "Join Project" button.

* GitHub: github.com/rwandaonrails/resource_tracking/

### RVM & Bundler

We use RVM+Bundler to standardize the Ruby and Gem environments across developers and to help new devs get up and running quickly.

  * Install RVM

  * Set your RVM ruby version

        $ rvm install ruby-1.8.7-p299
        $ rvm use ruby-1.8.7-p299

  * Create a "hrt_rwanda" gemset

        $ rvm gemset create 'hrt_rwanda'

  * Install bundler for this gemset

        $ gem install --no-rdoc --no-ri bundler

  * Bundler go!

        $ bundle install

Note: if you have an error in forms like "{{attribute}} {{message}}" manually uninstall the "i18n" gem (it is installed as a dependency of formtastic gem and used in Rails 3)


### Local Setup

Database:

  cp config/database.yml.sample config/database.yml

Edit config/database.yml per your environment.  This file is not tracked by git.

  rake db:schema:load

  rake db:seed

  rake db:populate


### Feature Dev

Setup test DB

  rake db:create RAILS_ENV=test
  rake db:schema:load RAILS_ENV=test

Tests/TDD - before every commit, and after every fetch, is your friend.

  $ rake test

Develop on a local feature branch (as per: http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html). Let Greg / the mailing list know if you have any questions.

#### Git

See doc/GIT_WORKFLOW.rdoc

### Releases

We follow Nvie.com's 'git workflow'.

### Deploying

Configure git

  # Heroku Prod remote
  [remote "heroku_production"]
    url = git@heroku.com:resourcetracking.git
    fetch = +refs/heads/*:refs/remotes/production/*

git push heroku_production master
    

### Release naming

We are using names of [Rwandan cities](http://en.wikipedia.org/wiki/List_of_cities_in_Rwanda) for each minor release.
