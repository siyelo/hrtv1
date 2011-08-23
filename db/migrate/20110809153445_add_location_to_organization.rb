
Organization.class_eval do
  has_and_belongs_to_many :locations # was removed in nearby migration
                                     # make sure dbm doesnt fail during release
end

class AddLocationToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :location_id, :integer
    Organization.all.each do |org|
      org.location = org.locations.first
      org.save(false)
    end
    drop_table :locations_organizations
  end

  def self.down
    create_table :locations_organizations, :id => false do |t|
      t.references :location
      t.references :organization
    end
    Organization.all.each do |org|
      org.locations << org.location
      org.save(false)
    end
    remove_column :organizations, :location_id, :integer
  end
end
