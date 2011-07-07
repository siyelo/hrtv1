class CopyDescriptionToName < ActiveRecord::Migration
  def self.up
    load 'db/fixes/copy_description_to_name.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
