class FixProjectActivityAssocTableToConformToRailsLexicalOrderingConvention < ActiveRecord::Migration
  def self.up
    drop_table :projects_activities

    create_table :activities_projects, :id => false do |t|
      t.references :project
      t.references :activity
    end
  end

  def self.down
    drop_table :activities_projects

    create_table :projects_activities, :id => false do |t|
      t.references :project
      t.references :activity
    end
  end
end
