class RemoveCodeTypeFromCodeAssignments < ActiveRecord::Migration
  def self.up
    remove_column :code_assignments, :code_type
  end

  def self.down
    add_column :code_assignments, :code_type, :string
  end
end
