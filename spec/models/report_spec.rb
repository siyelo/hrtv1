require File.dirname(__FILE__) + '/../spec_helper'

describe Report do
  
  describe "creating a record" do
    before :each do
      csv_report  = Reports::UsersByOrganization.new
      csv_report.stub(:csv).and_return('1,1,1')
      Reports::UsersByOrganization.stub(:new).and_return(csv_report)
    end  
    
    subject { Report.new(:key => 'somekey') }
    
    it { should be_valid }
    it { should validate_presence_of(:key) }
    it { should allow_mass_assignment_of(:key) }
      
    it "should only accept unique keys" do
      Report.create!(:key => 'users_by_organization')
      Report.new.should validate_uniqueness_of( :key )
    end

    it "should save a csv attachment" do
      report      = Report.new(:key => 'users_by_organization')    
      report.should_receive(:save_attached_files).and_return(true)
      report.save.should == true
    end
  end  
end