class FixDataResponses < ActiveRecord::Migration
  def self.up
    DataResponse.reset_column_information
    load 'db/fixes/20110705_fix_data_responses.rb'
  end

  def self.down
  end
end
