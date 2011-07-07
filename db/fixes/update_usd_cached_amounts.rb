#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "../../../config/environment")

load 'db/fixes/update_usd_cached_amounts_for_activities.rb'
load 'db/fixes/update_usd_cached_amounts_for_code_assignments.rb'
