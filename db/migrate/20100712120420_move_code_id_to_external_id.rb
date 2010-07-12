class MoveCodeIdToExternalId < ActiveRecord::Migration

  def self.up
    add_column :codes, :external_id, :string
  end

  def self.down
    remove_column :codes, :external_id
  end

end
