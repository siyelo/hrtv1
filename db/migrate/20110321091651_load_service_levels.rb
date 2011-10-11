class LoadServiceLevels < ActiveRecord::Migration
  def self.up
    #if Rails.env != "test" && Rails.env != "cucumber"
      #load 'db/seed_files/service_levels.rb'
    #end
  end

  def self.down
  end
end
