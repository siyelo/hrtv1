require 'fastercsv'

class Reports::ActivitiesByBudgetDistricts
  include Reports::Helpers

  def initialize
    codes         = Location.all
    code_ids      = codes.map{|code| code.id}
    beneficiaries = get_beneficiaries

    @csv_string   = FasterCSV.generate do |csv|
      csv << build_header(beneficiaries, codes)

      root_activities.each do |activity|
        if activity.projects.empty?
          csv << build_row(activity, beneficiaries, code_ids, " ")
        else
          activity.projects.each do |project|
            csv << build_row(activity, beneficiaries, code_ids, "#{h project.name}")
          end
        end
      end
    end
  end

  def csv
    @csv_string
  end

  private

    def build_header(beneficiaries, codes)
      row = []

      row << "funding_source"
      row << "project"
      row << "org.name"
      row << "org.type"
      row << "activity.id"
      row << "activity.name"
      row << "activity.description"
      beneficiaries.each{|beneficiary| row << "#{beneficiary}"}
      row << "activity.text_for_beneficiaries"
      row << "activity.text_for_targets"
      row << "activity.budget"
      row << "activity.spend"
      row << "currency"
      row << "activity.start"
      row << "activity.end"
      row << "activity.provider"
      codes.each{|code| row << "#{code}"}

      row
    end

    def build_row(activity, beneficiaries, code_ids, project_name)
      org        = activity.data_response.responding_organization
      act_benefs = activity.beneficiaries.map(&:short_display)
      act_codes  = activity.budget_district_coding.map(&:code_id)
      row        = []

      row << get_funding_source_name(activity)
      row << project_name
      row << "#{h org.name}"
      row << "#{org.type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      beneficiaries.each{|beneficiary| row << (act_benefs.include?(beneficiary) ? "yes" : " " )}
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.text_for_targets}"
      row << "#{activity.budget}"
      row << "#{activity.spend}"
      row << "#{activity.data_response.currency}"
      row << "#{activity.start}"
      row << "#{activity.end}"
      row << provider_name(activity)
      code_ids.each{|code_id| row << get_code_assignment_value(activity, act_codes, code_id)}

      row
    end

    def get_code_assignment_value(activity, act_codes, code_id)
      if act_codes.include?(code_id)
        ca = CodingBudgetDistrict.find(:first, :conditions => {:activity_id => activity.id, :code_id => code_id})
         ca ? ca.cached_amount : 0
      else
        nil
      end
    end
end

