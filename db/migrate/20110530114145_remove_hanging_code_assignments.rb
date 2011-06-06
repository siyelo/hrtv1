class RemoveHangingCodeAssignments < ActiveRecord::Migration
  def self.up
    total = 0

    CodeAssignment.find(:all, :include => [:activity, :code]).each do |ca|
      if ca.activity.nil? || ca.code.nil?
        ca.delete
        total += 1
      end
    end

    puts "Deleted #{total} code assignments."
  end

  def self.down
    puts "irreversible migration"
  end
end
