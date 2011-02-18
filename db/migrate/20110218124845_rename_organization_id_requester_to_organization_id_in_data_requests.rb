class RenameOrganizationIdRequesterToOrganizationIdInDataRequests < ActiveRecord::Migration
  def self.up
    rename_column :data_requests, :organization_id_requester, :organization_id
  end

  def self.down
    rename_column :data_requests, :organization_id, :organization_id_requester
  end
end
