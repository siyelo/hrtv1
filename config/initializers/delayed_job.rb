# the exact error is `uninitialized constant Delayed::Job`
# in your config/initializers/delayed_job.rb

Delayed::Worker.backend = :active_record
require 'importer'
#require 'implementer_split'
