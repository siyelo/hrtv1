#!/usr/bin/env ruby

# CI server test script
#   Runs all specs and cukes

# Usage:
#  !/bin/bash
#  source /var/lib/jenkins/.rvm/scripts/rvm
#  source $WORKSPACE/.rvmrc_ree
#  $WORKSPACE/script/ci/ci.rb
#

require File.join(File.dirname(__FILE__), '../../lib/', 'script_helper')
include ScriptHelper

WORKSPACE=ENV['WORKSPACE']

def bundle_install
  result = run "bundle check"
  run_or_die "bundle install" unless result == true
end

def setup_sqlite
  #run_or_die "cp #{WORKSPACE}/config/database.yml.sample.sqlite3 #{WORKSPACE}/config/database.yml"
  run "cp #{WORKSPACE}/config/database.yml.sample.sqlite3 #{WORKSPACE}/config/database.yml"
end

def setup_specs
  ENV['RAILS_ENV'] = 'test'
  run "gem uninstall rake -v=0.9.2"
  run_or_die "rake setup_quick --trace"
end

def specs
  setup_specs
  run_or_die "spec spec"
  #run_or_die "spec spec/models/<pick_some_quick_spec>.rb" #debug
end

# http://blog.kabisa.nl/2010/05/24/headless-cucumbers-and-capybaras-with-selenium-and-hudson/
# and http://markgandolfo.com/2010/07/01/hudson-ci-server-running-cucumber-in-headless-mode-xvfb
def setup_cukes
  ENV['RAILS_ENV'] = 'cucumber'
  ENV['DISPLAY'] = ":99"
  run "/etc/init.d/xvfb start"
end

def teardown_cukes
  run "/etc/init.d/xvfb stop"
end

def cukes
  setup_cukes
  run_or_die "rake cucumber"
  #run_or_die "rake cucumber:run" #for debug
  teardown_cukes
end

# main
bundle_install
setup_sqlite
specs
#cukes - ffox busting its nut on CI server. Not worth the trouble.

