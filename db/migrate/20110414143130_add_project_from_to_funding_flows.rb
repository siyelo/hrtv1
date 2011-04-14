class AddProjectFromToFundingFlows < ActiveRecord::Migration
  def self.up
    add_column :funding_flows, :project_from_id, :integer
  end

  def self.down
    remove_column :funding_flows, :project_from_id
  end
end
