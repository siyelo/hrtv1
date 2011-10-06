require 'iconv'
class Report < ActiveRecord::Base

  include ScriptHelper

  ### Associations
  belongs_to :data_request

  ### Constants
  REPORTS = [
    'districts_by_nsp_budget',
    'districts_by_all_codes_budget',
    'users_by_organization',
    'map_districts_by_nsp_budget',
    'map_districts_by_all_codes_budget',
    'map_facilities_by_partner_budget',
    'map_facilities_by_partner_spent',
    'activities_by_budget_coding',
    'activities_by_budget_cost_categorization',
    'activities_by_expenditure_coding',
    'activities_by_expenditure_cost_categorization',
    'dynamic_query_report_budget',
    'dynamic_query_report_spent',
    'activities_by_nsp_budget',
    'activities_by_nha',
    'activities_by_all_codes_budget'
  ]

  ### Attributes
  attr_accessible :key, :csv, :formatted_csv, :data_request_id
  attr_accessor :report, :raw_csv, :temp_file_name, :zip_file_name

  ### Attachments
  has_attached_file :csv, Settings.paperclip.to_options
  has_attached_file :formatted_csv, Settings.paperclip.to_options

  ### Validations
  validates_presence_of :key, :data_request_id
  validates_uniqueness_of :key, :scope => :data_request_id
  validates_inclusion_of :key, :in => REPORTS

  ### Callbacks
  after_save :cleanup_temp_files

  ### Instance Methods

  def to_s
    self.key
  end

  def generate_csv_zip
    run_report
    create_tmp_csv
    zip_file
    attach_zip_file
  end

  protected

    def run_report
      self.report =
        case key
        when 'districts_by_nsp_budget'
          Reports::DistrictsByNsp.new(simple_activities_for_request, :budget)
        when 'districts_by_all_codes_budget'
          Reports::DistrictsByAllCodes.new(simple_activities_for_request, :budget)
        when 'users_by_organization'
          Reports::UsersByOrganization.new
        when 'map_districts_by_nsp_budget'
          Reports::MapDistrictsByNsp.new(simple_activities_for_request, :budget)
        when 'map_districts_by_all_codes_budget'
          Reports::MapDistrictsByAllCodes.new(simple_activities_for_request, :budget)
        when 'map_facilities_by_partner_budget'
          Reports::MapFacilitiesByPartner.new(:budget, data_request)
        when 'map_facilities_by_partner_spent'
          Reports::MapFacilitiesByPartner.new(:spent, data_request)
        when 'activities_by_budget_coding'
          Reports::ActivitiesByCoding.new(:budget, data_request)
        when 'activities_by_budget_cost_categorization'
          Reports::ActivitiesByCostCategorization.new(:budget, data_request)
        when 'activities_by_expenditure_coding'
          Reports::ActivitiesByCoding.new(:spent, data_request)
        when 'activities_by_expenditure_cost_categorization'
          Reports::ActivitiesByCostCategorization.new(:spent, data_request)
        when 'dynamic_query_report_budget'
          Reports::JawpReport.new(:budget, simple_activities_for_request_with_associations)
        when 'dynamic_query_report_spent'
          Reports::JawpReport.new(:spent, simple_activities_for_request_with_associations)
        when 'activities_by_nsp_budget'
          Reports::ActivitiesByNsp.new(simple_activities_for_request, :budget)
        when 'activities_by_nha'
          Reports::ActivitiesByNha.new(simple_activities_for_request)
        when 'activities_by_all_codes_budget'
          Reports::ActivitiesByAllCodes.new(simple_activities_for_request, :budget)
        else
          raise "Invalid report request '#{self.key}'"
        end
      self.raw_csv = report.csv #force the report to run.
    end

    def create_tmp_csv
      self.temp_file_name = "#{RAILS_ROOT}/tmp/#{self.key}_#{data_request_id}_#{get_date()}.csv"
      # Convert to Windows-1252 encoding because Excel <2007 does not
      # recognize UTF8 encoded files.
      # self.raw_csv = Iconv.conv("WINDOWS-1252//IGNORE", "UTF-8", self.raw_csv)
      self.raw_csv = self.raw_csv
      File.open(self.temp_file_name, 'w')  {|f| f.write(self.raw_csv)}
    end

    def zip_file
      self.zip_file_name = self.temp_file_name + ".zip"
      cmd = "zip -j -9 #{self.zip_file_name} #{self.temp_file_name}"
      output = %x(#{cmd})
    end

    def attach_zip_file
      self.csv = File.new(self.zip_file_name, 'r')
    end

    def cleanup_temp_files
      File.delete self.temp_file_name if self.temp_file_name
      File.delete self.zip_file_name if self.zip_file_name
    end

    def simple_activities_for_request_with_associations
      simple_activities_for_request.find(:all,
        :include => [:provider, :beneficiaries,
                      {:data_response => :organization}])
    end

    def simple_activities_for_request
      Activity.only_simple_with_request(self.data_request)
    end
end

# == Schema Information
#
# Table name: reports
#
#  id                         :integer         not null, primary key
#  key                        :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  csv_file_name              :string(255)
#  csv_content_type           :string(255)
#  csv_file_size              :integer
#  csv_updated_at             :datetime
#  formatted_csv_file_name    :string(255)
#  formatted_csv_content_type :string(255)
#  formatted_csv_file_size    :integer
#  formatted_csv_updated_at   :datetime
#  data_request_id            :integer
#

