class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index "activities", ["activity_id"]
    add_index "activities", ["data_response_id"]
    add_index "activities", ["provider_id"]
    add_index "activities", ["type"]
    
    add_index "code_assignments", ["activity_id", "code_id", "type"]
    add_index "code_assignments", ["code_id"]

    add_index "data_responses", ["organization_id_responder"]
    
    add_index "funding_flows", ["organization_id_from", "organization_id_to"]
    add_index "funding_flows", ["organization_id_to", "organization_id_from"]
    add_index "funding_flows", ["project_id"]
    add_index "funding_flows", ["self_provider_flag"]
    add_index "funding_flows", ["data_response_id"]
 
    add_index "projects", ["data_response_id"]
  end

  def self.down
    remove_index "activities", ["activity_id"]
    remove_index "activities", ["data_response_id"]
    remove_index "activities", ["provider_id"]
    remove_index "activities", ["type"]
    
    remove_index "code_assignments", ["activity_id", "code_id", "type"]
    remove_index "code_assignments", ["code_id"]

    remove_index "data_responses", ["organization_id_responder"]
    
    remove_index "funding_flows", ["organization_id_from", "organization_id_to"]
    remove_index "funding_flows", ["organization_id_to", "organization_id_from"]
    remove_index "funding_flows", ["project_id"]
    remove_index "funding_flows", ["self_provider_flag"]
    remove_index "funding_flows", ["data_response_id"]
 
    remove_index "projects", ["data_response_id"]
  end
end
