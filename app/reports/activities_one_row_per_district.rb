require 'fastercsv'

class Reports::ActivitiesOneRowPerDistrict
  include Reports::Helpers

  def initialize
    @locations = Location.roots.collect{|code| code.self_and_descendants}.flatten
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header

      #
      # NOTE: can't eager load :projects association because
      # sub_activity delegates it to activity and there is some problem
      #
      #Activity.find(:all, :conditions => ['id IN (?)', [4760]]).each do |activity| # DEBUG ONLY
      #Activity.find(:all, :conditions => ['id IN (?)', [1416]]).each do |activity| # DEBUG ONLY
      Activity.find(:all, :include => :provider).each do |activity|
        if ((activity.class == Activity && activity.sub_activities.empty?) ||
            activity.class == SubActivity)
          build_rows(csv, activity)
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
     row << "activity.budget"
     row << "activity.spend"
     row << "currency"
     row << "activity.start"
     row << "activity.end"
     row << "activity.provider"
     row << "activity.provider.FOSAID"
     row << "activity.text_for_beneficiaries"
     row << "activity.text_for_targets"
     row << "Is Sub Activity?"
     row << "parent_activity.total_budget"
     row << "parent_activity.total_spend"
     @locations.each{|code| row << code.to_s_with_external_id}
     row << "District"
     row << "District Value"

     row
    end

    def build_rows(csv, activity)
      row = []

      row << get_funding_source_name(activity)
      row << first_project(activity)
      row << "#{h activity.organization.name}"
      row << "#{activity.organization.type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      row << "#{activity.budget}"
      row << "#{activity.spend}"
      row << "#{activity.currency}"
      row << "#{activity.start}"
      row << "#{activity.end}"
      row << provider_name(activity)
      row << provider_fosaid(activity)
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.text_for_targets}"
      row << is_activity(activity)
      row << parent_activity_budget(activity)
      row << parent_activity_spend(activity)
      @locations.each{|location| row << get_value(activity, location)}

      # add row per each activity location
      activity.locations.each do |location|
        location_row = row.dup
        location_row << location.short_display
        location_row << get_value(activity, location)

        csv << location_row
      end
    end

    def get_value(activity, location)
      code_assignments = activity.budget_district_coding.select{|ca| ca.code_id == location.id}
      code_assignments = code_assignments.last
      code_assignments ? code_assignments.calculated_amount : " "
    end
end
