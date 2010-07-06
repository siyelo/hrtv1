class AddCodesToActivity < ActiveRecord::Migration
  def self.up
    create_table :activities_codes, :id=>false do |t|
      t.references :activity
      t.references :code
    end
  end

  def self.down
    drop_table :activities_codes
  end
end
