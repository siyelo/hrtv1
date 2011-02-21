require 'fastercsv'

class Reports::ActivitiesByDistricts
  include Reports::Helpers

  def initialize(type)
    @is_budget    = is_budget?(type)
    @codes         = get_codes
    @code_ids      = @codes.map{|code| code.id}
    @beneficiaries = get_beneficiaries
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header

      root_activities.each do |activity|
        if activity.projects.empty?
          csv << build_row(activity, " ")
        else
          activity.projects.each do |project|
            csv << build_row(activity, "#{h project.name}")
          end
        end
      end
    end
  end

  private

    def build_header
      row = []

      row << "funding_source"
      row << "project"
      row << "org.name"
      row << "org.type"
      row << "activity.id"
      row << "activity.name"
      row << "activity.description"
      @beneficiaries.each{|beneficiary| row << "#{beneficiary}"}
      row << "activity.text_for_beneficiaries"
      row << "activity.text_for_targets"
      row << "activity.budget"
      row << "activity.spend"
      row << "currency"
      row << "activity.start"
      row << "activity.end"
      row << "activity.provider"
      @codes.each{|code| row << "#{code.short_display}"}

      row
    end

    def build_row(activity, project_name)
      act_benefs = activity.beneficiaries.map{|code| code.short_display}
      if @is_budget
        code_assignments = activity.budget_district_coding_adjusted.map(&:code_id)
      else
        code_assignments = activity.spend_district_coding_adjusted.map(&:code_id)
      end
      row = []

      row << funding_source_name(activity)
      row << project_name
      row << "#{h activity.organization.name}"
      row << "#{activity.organization.type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      @beneficiaries.each{|beneficiary| row << (act_benefs.include?(beneficiary) ? "yes" : " " )}
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.text_for_targets}"
      row << "#{activity.budget_in_usd}"
      row << "#{activity.spend_in_usd}"
      row << "#{activity.data_response.currency}"
      row << "#{activity.start}"
      row << "#{activity.end}"
      row << provider_name(activity)
      @code_ids.each{|code_id| row << get_code_assignment_value(activity, code_assignments, code_id)}

      row
    end

    def get_codes
      Location.all
    end

    def get_code_assignment_value(activity, code_assignments, code_id)
      if code_assignments.include?(code_id)
        if @is_budget
          ca = CodingBudgetDistrict.find(:first, :conditions => {:activity_id => activity.id, :code_id => code_id})
        else
          ca = CodingSpendDistrict.find(:first, :conditions => {:activity_id => activity.id, :code_id => code_id})
        end
        ca ? ca.cached_amount_in_usd : 0
      else
        nil
      end
    end
end

