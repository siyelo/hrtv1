class RemoveAbilitiesTable < ActiveRecord::Migration
  def self.up
    drop_table :abilities
  end

  def self.down
    create_table :abilities do |t|

      t.timestamps
    end
  end
end
