class RemoveActivitiesIndicatorsTable < ActiveRecord::Migration
  def self.up
    drop_table "activities_indicators"
  end

  def self.down
    create_table "activities_indicators", :id => false, :force => true do |t|
      t.integer "activity_id"
      t.integer "indicator_id"
    end
  end
end
