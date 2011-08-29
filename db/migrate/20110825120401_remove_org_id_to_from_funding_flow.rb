class RemoveOrgIdToFromFundingFlow < ActiveRecord::Migration
  def self.up
    remove_column :funding_flows, :organization_id_to
  end

  def self.down
    add_column :funding_flows, :organization_id_to, :integer
  end
end
