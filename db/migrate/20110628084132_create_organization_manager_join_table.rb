class CreateOrganizationManagerJoinTable < ActiveRecord::Migration
  def self.up
    create_table :organizations_managers, :id => false do |t|
      t.integer :organization_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :organizations_managers
  end
end
