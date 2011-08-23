class RemoveInvalidFlows < ActiveRecord::Migration
  def self.up
    puts "Removing the invalid funding flows"
    amount = FundingFlow.all.inject(0){|sum, ff| (sum+=1; ff.delete) unless ff.valid?; sum}
    puts "#{amount} invalid funding flows destroyed"
  end

  def self.down
    puts "Irreversible migration"
  end
end
