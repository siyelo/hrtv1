require 'fastercsv'

class Reports::ActivitiesByDistrictOld
  include Reports::Helpers

  def initialize
    locations     = Location.find(:all, :select => 'id, short_display', :order => "short_display ASC")#.map(&:short_display).sort
    beneficiaries = Beneficiary.find(:all, :select => 'short_display').map(&:short_display).sort

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header(beneficiaries, locations)

      #print data
      Activity.find(:all, :include => :code_assignments).each do |a|
        row = build_row(a, beneficiaries, locations)
        #print out a row for each project
        if a.projects.empty?
          row.unshift(" ")
          csv << row.flatten
        else
          a.projects.each do |proj|
            proj_row = row.dup
            proj_row.unshift("#{h proj.name}")
            csv << proj_row.flatten
          end
        end
      end
    end
  end

  def csv
    @csv_string
  end

  protected

  def build_header(beneficiaries, locations)
    #print header
    header = []
    header << [ "project", "org.name", "org.type", "activity.name", "activity.description" ]
    beneficiaries.each do |ben|
      header << "#{ben}"
    end
    header << ["activity.text_for_beneficiaries", "activity.text_for_targets", "activity.target", "activity.budget", "activity.spend", "currency", "activity.start", "activity.end", "activity.provider"]
    locations.each { |loc| header << "#{loc.short_display}" }
    header.flatten
  end

  def build_row(activity, beneficiaries, locations)
    org        = activity.data_response.organization
    act_benefs = activity.beneficiaries.map(&:short_display)
    act_locs   = activity.locations.map(&:short_display)

    row = []
    row << [ "#{h org.name}", "#{org.type}", "#{h activity.name}", "#{h activity.description}" ]
    beneficiaries.each do |ben|
      row << (act_benefs.include?(ben) ? "yes" : " " )
    end
    row << ["#{h activity.text_for_beneficiaries}", "#{h activity.text_for_targets}", "#{activity.target}", "#{activity.budget}", "#{activity.spend}", "#{activity.data_response.currency}", "#{activity.start}", "#{activity.end}" ]
    row << (activity.provider.nil? ? " " : "#{ activity.provider.name}" )

    locations.each do |loc|
      if act_locs.include?(loc.short_display)
        row << get_amount(activity, loc)
      else
        row << " "
      end
    end

    row.flatten
  end
end
