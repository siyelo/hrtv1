class RemoveHangingFundingFlows < ActiveRecord::Migration
  def self.up
    FundingFlow.all.each do |ff|
      ff.delete if ff.data_response.nil?
    end
  end

  def self.down
     puts "irreversible migration - data fix"
  end
end
