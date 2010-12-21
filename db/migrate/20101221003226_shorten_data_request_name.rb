class ShortenDataRequestName < ActiveRecord::Migration
  def self.up
    d = DataRequest.first
    d.title = "FY2010 Workplan and FY2009 Expenditures"
    d.save(false)
  end

  def self.down
    d = DataRequest.first
    d.title = "FY2010 Workplan and FY2009 Expenditures - due date September 1"
    d.save(false)
  end
end
