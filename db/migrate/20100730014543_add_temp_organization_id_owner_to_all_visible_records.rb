#we will later replace this with a lookup that this element 
#is in the current data response
class AddTempOrganizationIdOwnerToAllVisibleRecords < ActiveRecord::Migration
  def self.up
    %w[projects activities].each do |t|
      add_column t, :organization_id_owner, :integer
    end
  end

  def self.down
    %w[projects activities].each do |t|
      remove_column t, :organization_id_owner
    end
  end
end
