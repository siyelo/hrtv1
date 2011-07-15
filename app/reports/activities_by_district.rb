require 'fastercsv'

class Reports::ActivitiesByDistrict
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
          csv << build_row(activity)
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
     row << "activity.start_date"
     row << "activity.end_date"
     row << "activity.provider"
     row << "activity.provider.FOSAID"
     row << "activity.text_for_beneficiaries"
     row << "activity.targets"
     row << "Is Implementer?"
     row << "parent_activity.total_budget"
     row << "parent_activity.total_spend"
     @locations.each{|location| row << location.to_s_with_external_id}

     row
    end

    def build_row(activity)
      #TODO handle implementers correctly

      row = []

      row << funding_source_name(activity)
      row << activity.project.try(:name)
      row << "#{h activity.organization.name}"
      row << "#{activity.organization.type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      row << "#{activity.budget_in_usd}"
      row << "#{activity.spend_in_usd}"
      row << "#{activity.currency}"
      row << "#{activity.start_date}"
      row << "#{activity.end_date}"
      row << provider_name(activity)
      row << provider_fosaid(activity)
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.outputs.map{|o| o.description}.join('; ')}"
      row << is_activity(activity)
      row << parent_activity_budget(activity)
      row << parent_activity_spend(activity)
      @locations.each{|location| row << location_included?(activity, location)}

      row
    end

    def location_included?(activity, code)
      activity.locations.include?(code) ? "yes" : " "
    end
end
