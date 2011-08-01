class AddDueDateToRequest < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :due_date,    :date
  end

  def self.down
    remove_column :data_requests, :due_date
  end
end
