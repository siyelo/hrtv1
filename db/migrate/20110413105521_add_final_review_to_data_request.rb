class AddFinalReviewToDataRequest < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :final_review, :boolean, :default => false
    remove_column :data_requests, :pending_review
    remove_column :data_requests, :complete
  end

  def self.down
    add_column :data_requests, :pending_review, :boolean
    add_column :data_requests, :complete, :boolean
    remove_column :data_requests, :final_review
  end
end
