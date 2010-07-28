class AddTypeToCodeAssignments < ActiveRecord::Migration
  def self.up
    add_column :code_assignments, :type, :string
  end

  def self.down
    remove_column :code_assignments, :type
  end

end
