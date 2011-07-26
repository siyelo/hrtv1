class AddBackRemovedCodeAssignments < ActiveRecord::Migration
  def self.up
    load 'db/fixes/code_assignments/add_back_removed_code_assignments.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
