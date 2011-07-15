class RemoveDuplicateCodeAssignments < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110715_remove_duplicate_code_assignments.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
