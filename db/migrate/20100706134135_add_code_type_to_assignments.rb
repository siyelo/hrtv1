class AddCodeTypeToAssignments < ActiveRecord::Migration
  def self.up
    add_column :code_assignments, :code_type, :string
  end

  def self.down
  end
end
