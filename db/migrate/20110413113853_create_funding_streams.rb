class CreateFundingStreams < ActiveRecord::Migration
  def self.up
    create_table :funding_streams do |t|
      t.integer :project_id
      t.integer :organization_ufs_id
      t.integer :organization_fa_id

      t.timestamps
    end
  end

  def self.down
    drop_table :funding_streams
  end
end
