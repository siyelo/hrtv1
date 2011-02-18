class Report < ActiveRecord::Base
  include ScriptHelper


  REPORTS = [
    'districts_by_nsp_budget',
    'districts_by_all_codes_budget',
    'users_by_organization',
    'map_districts_by_partner_budget',
    'map_districts_by_partner_spent',
    'map_districts_by_nsp_budget',
    'map_districts_by_all_codes_budget',
    'map_facilities_by_partner_budget',
    'map_facilities_by_partner_spent',
    'activities_summary',
    'activities_by_district',
    'activities_one_row_per_district',
    'activities_by_budget_coding',
    'activities_by_budget_cost_categorization',
    'activities_by_budget_districts',
    'activities_by_expenditure_coding',
    'activities_by_expenditure_cost_categorization',
    'activities_by_expenditure_districts',
    'jawp_report_budget',
    'jawp_report_spent',
    'activities_by_nsp_budget',
    'activities_by_nha',
    'activities_by_all_codes_budget'
  ]

  attr_accessible :key, :csv, :formatted_csv
  attr_accessor :report, :raw_csv, :temp_file_name, :zip_file_name
  has_attached_file :csv, Settings.paperclip.to_options
  has_attached_file :formatted_csv, Settings.paperclip.to_options

  validates_presence_of :key
  validates_uniqueness_of :key
  validates_inclusion_of :key, :in => REPORTS

  after_save :cleanup_temp_files

  ### Instance Methods

  def to_s
    self.key
  end

  def generate_csv_zip
    self.run_report
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
      self.temp_file_name = "#{RAILS_ROOT}/tmp/#{self.key}_#{get_date()}.csv"
      File.open(self.temp_file_name, 'w')  {|f| f.write(self.raw_csv) }
    end

    def zip_file
      self.zip_file_name = self.temp_file_name + ".zip"
      cmd = "zip -j -9 #{self.zip_file_name} #{self.temp_file_name}"
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
#  formatted_csv_updated_at   :datetime
#

