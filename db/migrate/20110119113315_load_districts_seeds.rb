class LoadDistrictsSeeds < ActiveRecord::Migration
  def self.up
    if Rails.env != "test" && Rails.env != "cucumber"
      load 'db/seed_files/district_details.rb'
    end
  end

  def self.down
  end
end
