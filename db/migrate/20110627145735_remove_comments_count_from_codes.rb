class RemoveCommentsCountFromCodes < ActiveRecord::Migration
  def self.up
    remove_column :codes, :comments_count
  end

  def self.down
    add_column :codes, :comments_count, :integer
  end
end
