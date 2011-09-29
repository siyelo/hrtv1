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
    subject { Report.create!(:key => 'users_by_organization', :data_request_id => Factory(:data_request).id)}
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
      report        = Report.new(:key => 'users_by_organization',
                                 :data_request_id => @request.id)
      report.should_receive(:save_attached_files).twice.and_return(true)
      report.save.should == true
    end
  end

  describe "Encoding" do
    it "should encode csv files as Windows-1252" do
      @request      = Factory(:data_request)
      @organization = Factory(:organization, :name => "ààââàûçÿ",
                              :raw_type => 'Bilateral')
      @user         = Factory(:user, :organization => @organization)
      report        = Report.new(:key => 'users_by_organization',
                                 :data_request_id => @request.id)
      report.generate_csv_zip
      converted_csv = Iconv.conv("UTF-8","WINDOWS-1252",report.raw_csv)
      converted_csv.split("\n")[1].should == "1,#{@user.email},#{@user.name},ààââàûçÿ,Bilateral,Not Yet Started"
    end
  end

  describe "#generate_csv_zip" do
    before :each do
      mtef_code     = Factory(:mtef_code)
      nsp_code      = Factory(:nsp_code)
      cc_code       = Factory(:cost_category_code)
      location      = Factory(:location)
      @organization = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response,
                              :project => @project)
      @sa           = Factory(:sub_activity, :data_response => @response,
                              :activity => @activity,
                              :budget => 10, :spend => 10)

      Factory(:coding_budget, :activity => @activity,
              :percentage => 100, :code => mtef_code)
      Factory(:coding_budget_district, :activity => @activity,
              :percentage => 100, :code => location)
      Factory(:coding_budget_cost_categorization, :activity => @activity,
              :percentage => 100, :code => cc_code)
    end


    Report::REPORTS.each do |key|
      it "creates a new: #{key}" do
        report = Report.find_or_initialize_by_key_and_data_request_id(key, @request.id)
        Report.count.should == 0
        report.generate_csv_zip
        report.save.should be_true
        Report.count.should == 1
      end
    end

    Report::REPORTS.each do |key|
      it "updates the existing: #{key}" do
        report = Report.create!(:key => key, :data_request_id => @request.id)
        Report.count.should == 1
        report.generate_csv_zip
        report.save.should be_true
        Report.count.should == 1
      end
    end
  end
end


# == Schema Information
#
# Table name: reports
#
#  id                         :integer         primary key
#  key                        :string(255)
#  created_at                 :timestamp
#  updated_at                 :timestamp
#  csv_file_name              :string(255)
#  csv_content_type           :string(255)
#  csv_file_size              :integer
#  csv_updated_at             :timestamp
#  formatted_csv_file_name    :string(255)
#  formatted_csv_content_type :string(255)
#  formatted_csv_file_size    :integer
#  formatted_csv_updated_at   :timestamp
#

