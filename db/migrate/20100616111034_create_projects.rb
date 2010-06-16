class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    create_table :projects_activities do |t|
      t.reference :project
      t.reference :activity
    end
  end

  def self.down
    drop_table :projects_activities

    drop_table :projects
  end
end
