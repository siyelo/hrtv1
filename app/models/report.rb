class Report < ActiveRecord::Base

  attr_accessible :key
  attr_accessor :report, :raw_csv, :temp_file_name, :zip_file_name
  has_attached_file :csv,
    {:path => "report/:attachment/:key.:extension"
    }.merge(Settings.paperclip.to_options)

  validates_presence_of :key
  validates_uniqueness_of :key

  before_save :generate_csv_zip
  after_save :cleanup_temp_files

  ### Instance Methods

  def to_s
    self.key
  end

  def generate
     self.run_report
  end

  def generate_csv_zip
    self.generate
    self.create_tmp_csv
    self.zip_file
    self.attach_zip_file
  end

  protected

    def run_report
      self.report =
        case self.key
        when 'districts_by_nsp_budget'
          Reports::DistrictsByNsp.new(Activity.only_simple.canonical, :budget)
        when 'districts_by_all_codes_budget'
          Reports::DistrictsByAllCodes.new(Activity.only_simple.canonical, :budget)
        when 'users_by_organization'
          Reports::UsersByOrganization.new
        when 'map_districts_by_partner_budget'
          Reports::MapDistrictsByPartner.new(:budget)
        when 'map_districts_by_partner_spent'
          Reports::MapDistrictsByPartner.new(:spent)
        when 'map_districts_by_nsp_budget'
          Reports::MapDistrictsByNsp.new(Activity.only_simple.canonical, :budget)
        when 'map_districts_by_all_codes_budget'
          Reports::MapDistrictsByAllCodes.new(Activity.only_simple.canonical, :budget)
        when 'map_facilities_by_partner_budget'
          Reports::MapFacilitiesByPartner.new(:budget)
        when 'map_facilities_by_partner_spent'
          Reports::MapFacilitiesByPartner.new(:spent)
        when 'activities_summary'
          Reports::ActivitiesSummary.new
        when 'activities_by_district'
          Reports::ActivitiesByDistrict.new
        when 'activities_one_row_per_district'
          Reports::ActivitiesOneRowPerDistrict.new
        when 'activities_by_budget_coding'
          Reports::ActivitiesByCoding.new(:budget)
        when 'activities_by_budget_cost_categorization'
          Reports::ActivitiesByCostCategorization.new(:budget)
        when 'activities_by_budget_districts'
          Reports::ActivitiesByDistricts.new(:budget)
        when 'activities_by_expenditure_coding'
          Reports::ActivitiesByCoding.new(:spent)
        when 'activities_by_expenditure_cost_categorization'
          Reports::ActivitiesByCostCategorization.new(:spent)
        when 'activities_by_expenditure_districts'
          Reports::ActivitiesByDistricts.new(:spent)
        when 'jawp_report_budget'
          Reports::JawpReport.new(:budget, Activity.jawp_activities)
        when 'jawp_report_spent'
          Reports::JawpReport.new(:spent, Activity.jawp_activities)
        when 'activities_by_nsp_budget'
          Reports::ActivitiesByNsp.new(Activity.only_simple.canonical, :budget, true)
        when 'activities_by_nha'
          Reports::ActivitiesByNha.new(Activity.only_simple.canonical)
        when 'activities_by_all_codes_budget'
          Reports::ActivitiesByAllCodes.new(Activity.only_simple.canonical, :budget, true)
        else
          raise "Invalid report request '#{self.key}'"
        end
      self.raw_csv = self.report.csv #force the report to run.
    end

    def create_tmp_csv
      self.temp_file_name = "#{RAILS_ROOT}/tmp/#{self.key}_#{Process.pid}.csv"
      File.open(self.temp_file_name, 'w')  {|f| f.write(self.raw_csv) }
    end

    def zip_file
      self.zip_file_name = self.temp_file_name + ".zip"
      cmd = "zip -9 #{self.zip_file_name} #{self.temp_file_name}"
      system cmd
    end

    def attach_zip_file
      self.csv = File.new(self.zip_file_name, 'r')
    end

    def cleanup_temp_files
      File.delete self.temp_file_name if self.temp_file_name
      File.delete self.zip_file_name if self.zip_file_name
    end
end


# == Schema Information
#
# Table name: reports
#
#  id               :integer         not null, primary key
#  key              :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  csv_file_name    :string(255)
#  csv_content_type :string(255)
#  csv_file_size    :integer
#  csv_updated_at   :datetime
#

