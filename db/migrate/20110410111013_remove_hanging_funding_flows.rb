class RemoveHangingFundingFlows < ActiveRecord::Migration
  def self.up
    puts "Before DB fix: #{FundingFlow.count} funding flows in database"
    FundingFlow.all.each do |ff|
      ff.delete unless ff.project and ff.data_response
    end
    puts "After DB fix: #{FundingFlow.count} funding flows in database"
  end

  def self.down
     puts "irreversible migration - data fix"
  end
end
