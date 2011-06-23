class FixDataResponses < ActiveRecord::Migration
  def self.up
    DataResponse.reset_column_information
    load 'db/fixes/20110623_add_data_responses.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
