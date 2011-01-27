class AddCreatedAndUpdatedAtToCodeAssignments < ActiveRecord::Migration
  def self.up
    change_table :code_assignments do |t|
      t.timestamps
    end
  end

  def self.down
    remove_column :code_assignments, :created_at, :datetime
    remove_column :code_assignments, :updated_at, :datetime
  end
end
