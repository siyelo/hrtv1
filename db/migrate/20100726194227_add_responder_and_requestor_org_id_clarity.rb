class AddResponderAndRequestorOrgIdClarity < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :organization_id_responder, :integer
    rename_column :data_requests, :organization_id, :organization_id_requester

  end

  def self.down

    rename_column :data_requests, :organization_id_requester, :organization_id
    remove_column :data_responses, :organization_id_responder
  end
end
