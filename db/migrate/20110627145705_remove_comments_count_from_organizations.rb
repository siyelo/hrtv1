class RemoveCommentsCountFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :comments_count
  end

  def self.down
    add_column :organizations, :comments_count, :integer
  end
end
