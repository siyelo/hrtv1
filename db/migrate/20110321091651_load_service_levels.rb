class LoadServiceLevels < ActiveRecord::Migration
  def self.up
    load 'db/seed_files/service_levels.rb'
  end

  def self.down
  end
end
