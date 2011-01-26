class LoadDistrictsSeeds < ActiveRecord::Migration
  def self.up
    load 'db/seed_files/districts_of_rwanda.rb'
  end

  def self.down
  end
end
