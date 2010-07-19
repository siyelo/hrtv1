class AddOrganizationToFundingFlow < ActiveRecord::Migration
  def self.up
    add_column :funding_flows, :organization_id_owner, :integer
  end

  def self.down
    remove_column :funding_flows, :organization_id_owner
  end
end
