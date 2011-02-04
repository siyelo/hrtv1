class RenameOrganizationIdResponderToOrganizationIdInDataResponses < ActiveRecord::Migration
  def self.up
    remove_index "data_responses", ["organization_id_responder"]
    rename_column :data_responses, :organization_id_responder, :organization_id
    add_index "data_responses", ["organization_id"]
  end

  def self.down
    remove_index "data_responses", ["organization_id"]
    rename_column :data_responses, :organization_id, :organization_id_responder
    add_index "data_responses", ["organization_id_responder"]
  end
end
