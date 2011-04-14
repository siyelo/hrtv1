class AddFinalSubmittedToDataResponse < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :submitted_for_final_at, :datetime
    add_column :data_responses, :submitted_for_final, :boolean
  end

  def self.down
    remove_column :data_responses, :submitted_for_final
    remove_column :data_responses, :submitted_for_final_at
  end
end
