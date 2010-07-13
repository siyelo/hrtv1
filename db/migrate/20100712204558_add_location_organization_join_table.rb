class AddLocationOrganizationJoinTable < ActiveRecord::Migration
  def self.up
    create_table :locations_organizations, :id => false do |t|
      t.references :location
      t.references :organization
    end
  end

  def self.down
    drop_table :locations_organizations
  end
end
