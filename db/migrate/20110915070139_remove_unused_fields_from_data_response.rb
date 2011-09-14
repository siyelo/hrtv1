class RemoveUnusedFieldsFromDataResponse < ActiveRecord::Migration
  def self.up
    remove_column :data_responses, :complete
    remove_column :data_responses, :submitted
    remove_column :data_responses, :submitted_at
    remove_column :data_responses, :submitted_for_final_at
    remove_column :data_responses, :submitted_for_final
  end

  def self.down
    add_column :data_responses, :complete, :boolean, :default => false
    add_column :data_responses, :submitted, :boolean
    add_column :data_responses, :submitted_at, :datetime
    add_column :data_responses, :submitted_for_final_at, :boolean
    add_column :data_responses, :submitted_for_final, :datetime
  end
end
