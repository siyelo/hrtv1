class RemoveCommentsCountFromDataResponses < ActiveRecord::Migration
  def self.up
    remove_column :data_responses, :comments_count
  end

  def self.down
    add_column :data_responses, :comments_count, :integer
  end
end
