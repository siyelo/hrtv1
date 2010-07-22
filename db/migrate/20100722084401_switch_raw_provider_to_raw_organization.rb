class SwitchRawProviderToRawOrganization < ActiveRecord::Migration
  def self.up
    remove_column :funding_flows, :raw_provider
    add_column :funding_flows, :organization_text, :text
  end

  def self.down
    remove_column :funding_flows, :organization_text
    add_column :funding_flows, :raw_provider, :text
  end
end
