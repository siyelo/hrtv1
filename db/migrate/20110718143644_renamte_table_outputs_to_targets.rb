class RenamteTableOutputsToTargets < ActiveRecord::Migration
  def self.up
    rename_table :outputs, :targets
  end

  def self.down
    rename_table :targets, :outputs
  end
end
