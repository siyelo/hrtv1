class PrepCodesForSti < ActiveRecord::Migration
  def self.up
    add_column :codes, :type, :string
  end

  def self.down
    remove_column :codes, :type
  end
end
