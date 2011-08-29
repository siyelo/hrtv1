class MoveImplementersToSubActivities < ActiveRecord::Migration

  def self.up
    batch_size = 2000
    last = Activity.only_simple.last
    if last
      last_id = last.id
      puts "found #{Activity.only_simple.count} activities"
      required_batches = (last_id/batch_size.to_f).ceil
      (0..required_batches-1).each do |i|
        lower = i * batch_size
        upper = lower + batch_size
        # puts "#{i} lower = #{lower}"
        # puts "     upper = #{upper}"
        self.run_cmd "ruby #{File.dirname(__FILE__)}/../fixes/move_implementers_to_sub_activities.rb", "activities.id >= #{lower} AND activities.id < #{upper}"
      end
    end
  end

  def self.down
    puts "irreversible"
  end

  def self.run_cmd(command, args)
    puts "running #{command} #{args}"
    unless system("#{command} \"#{args}\" 2>&1")
      puts "Command failed: #{command} \"#{args}\" 2>&1"
      exit(1)
    end
  end
end
