class MoveTextForTargetsToTargets < ActiveRecord::Migration
  def self.up
    activities     = Activity.find(:all, :conditions => "activities.type IS NULL")
    activity_total = activities.length
    activities.each_with_index do |activity, i|
      puts "Migrating targets for activity: #{activity.id} | #{i + 1}/#{activity_total}: "

      if activity.text_for_targets.present?
        activity.outputs.create!(:description => activity.text_for_targets)
      end
    end

    remove_column :activities, :text_for_targets
  end

  def self.down
    add_column :activities, :text_for_targets, :text
  end
end
