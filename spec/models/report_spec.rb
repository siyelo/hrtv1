require File.dirname(__FILE__) + '/../spec_helper'

describe Report do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:key) }
    it { should allow_mass_assignment_of(:data_request_id) }
    it { should allow_mass_assignment_of(:csv) }
    it { should allow_mass_assignment_of(:formatted_csv) }
  end

  describe "Associations" do
    it { should belong_to :data_request }
  end

  describe "Validations" do
    subject { Report.create!(:key => 'activity_overview', :data_request_id => Factory(:data_request).id)}
    it { should be_valid }
    it { should validate_presence_of(:key) }
    it { should validate_presence_of(:data_request_id) }
    it { should validate_uniqueness_of(:key).scoped_to(:data_request_id) }
    it "should accept only keys for certain Reports" do
      Report.new(:key => 'blahblah').should_not be_valid
    end
  end

  describe "Attachments" do
    it "should save attachments" do
      @request      = Factory(:data_request)
      report        = Report.new(:key => 'activity_overview',
                                 :data_request_id => @request.id)
      report.should_receive(:save_attached_files).twice.and_return(true)
      report.save.should == true
    end
  end

  describe "#generate_report" do
    before :each do
      mtef_code          = Factory(:mtef_code)
      nsp_code           = Factory(:nsp_code)
      cost_category_code = Factory(:cost_category_code)
      location           = Factory(:location)
      @organization      = Factory(:organization)
      @request           = Factory(:data_request, :organization => @organization)
      @response          = @organization.latest_response
      @project           = Factory(:project, :data_response => @response)
      @activity          = Factory(:activity, :data_response => @response,
                                   :project => @project)
      @split2            = Factory(:implementer_split, :activity => @activity,
                            :organization => @organization, :budget => 10, :spend => 10)
      Factory(:coding_budget, :activity => @activity,
              :percentage => 100, :code => mtef_code)
      Factory(:coding_budget_district, :activity => @activity,
              :percentage => 100, :code => location)
      Factory(:coding_budget_cost_categorization, :activity => @activity,
              :percentage => 100, :code => cost_category_code)
    end


    Report::REPORTS.each do |key|
      it "creates a new: #{key}" do
        report = Report.find_or_initialize_by_key_and_data_request_id(key, @request.id)
        Report.count.should == 0
        report.generate_report
        report.save.should be_true
        Report.count.should == 1
      end
    end

    Report::REPORTS.each do |key|
      it "updates the existing: #{key}" do
        report = Report.create!(:key => key, :data_request_id => @request.id)
        Report.count.should == 1
        report.generate_report
        report.save.should be_true
        Report.count.should == 1
      end
    end
  end

  describe "upload" do
    it "should unzip an uploaded file" do
      csv = Report.unzip_csv("#{RAILS_ROOT}/spec/fixtures/activity_overview.zip")
      csv.should == File.open("#{RAILS_ROOT}/spec/fixtures/activity_overview.csv").read
    end
  end

  describe "generate zip" do
    it "should create a temp zip file for user download" do
      @request      = Factory(:data_request)
      report        = Report.new(:key => 'activity_overview',
                                 :data_request_id => @request.id)
      report.temp_file_name = "#{RAILS_ROOT}/spec/fixtures/activity_overview.csv"
      report.send(:zip_file).should == "  adding: activity_overview.csv (deflated 50%)\n"
      %x(rm "#{report.zip_file_name}") ## removing the file it saved
    end
  end
end
