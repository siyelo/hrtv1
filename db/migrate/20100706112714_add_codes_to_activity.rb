class AddCodesToActivity < ActiveRecord::Migration
  def self.up
    create_table :code_assignments do |t|
      t.references :activity
      t.references :code
    end
  end

  def self.down
    drop_table :code_assignments
  end
end
