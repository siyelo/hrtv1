class ActivityTargetsShouldBe1ManyOrgs < ActiveRecord::Migration
  def self.up
    create_table :activities_organizations, :id=>false do |t|
      t.references :activities
      t.references :organizations
    end
  end

  def self.down
  end
end
