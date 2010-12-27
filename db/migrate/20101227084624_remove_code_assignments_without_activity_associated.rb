class RemoveCodeAssignmentsWithoutActivityAssociated < ActiveRecord::Migration
  def self.up
    load 'db/fixes/remove_code_assignments_without_activity_associated.rb'
  end

  def self.down
  end
end
