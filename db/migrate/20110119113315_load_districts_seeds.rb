class LoadDistrictsSeeds < ActiveRecord::Migration
  def self.up
    load 'db/seed_files/district_details.rb'
  end

  def self.down
  end
end
