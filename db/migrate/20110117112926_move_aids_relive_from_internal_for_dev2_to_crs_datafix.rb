class MoveAidsReliveFromInternalForDev2ToCrsDatafix < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110117_move_aids_relief_from_internal_for_dev2_to_crs.rb'
  end

  def self.down
  end
end
