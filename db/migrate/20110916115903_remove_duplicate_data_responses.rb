class RemoveDuplicateDataResponses < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110916_remove_duplicate_data_responses.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
