class AddPercentsToSubActivities < ActiveRecord::Migration
  def self.up
    ["budget", "spend"].each do |f|
      add_column :activities, f+"_percentage", :decimal
    end
  end

  def self.down
    ["budget", "spend"].each do |f|
      remove_column :activities, f+"_percentage"
    end
  end
end
