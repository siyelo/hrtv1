class AddTypeToActivitiesForStiForOtherCosts < ActiveRecord::Migration
  def self.up
    add_column :activities, :type, :string
  end

  def self.down
    remove_column :activities, :type
  end
end
