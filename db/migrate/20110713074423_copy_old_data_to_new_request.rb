class CopyOldDataToNewRequest < ActiveRecord::Migration
  def self.up
    load 'db/fixes/copy_old_data_to_new_request.rb'
  end

  def self.down
    puts 'irreversible migration!! Dont re-run!'
  end
end
