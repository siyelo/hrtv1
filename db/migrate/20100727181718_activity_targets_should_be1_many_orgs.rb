class ActivityTargetsShouldBe1ManyOrgs < ActiveRecord::Migration
  def self.up
    create_table :activities_organizations, :id=>false do |t|
      t.references :activity
      t.references :organization
    end
  end

  def self.down
    drop_table :activities_organizations
  end
end
