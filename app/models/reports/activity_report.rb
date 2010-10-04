require 'fastercsv'

class Reports::ActivityReport
  include Reports::Helpers

  attr_accessor :query, :cols, :conditions, :joins

  def initialize options = {}
#    cols = [ "project.name", "org.name", "org.type", "activity.name", "activity.description", 
#          "activity.text_for_beneficiaries", "activity.text_for_targets", "activity.target",
#          "activity.budget", "activity.spend", "currency","activity.start", "activity.end", 
#          "activity.provider"]
#    cols = (cols + options[:cols]).flatten if options[:cols]

    #add to cols only when you are doing a row join, not column join
    #dont do chaining yet, just one set of codes

    beneficiaries = Beneficiary.find(:all, :select => 'short_display').map(&:short_display).sort

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header(beneficiaries, codes)

      #print data
      Activity.all.each do |a|
        row = build_row(a, beneficiaries)
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

  def build_header(beneficiaries, codes)
    #print header
    header = []
    header << [ "project", "org.name", "org.type", "activity.name", "activity.description" ]
    beneficiaries.each do |ben|
      header << "#{ben}"
    end
    header << ["activity.text_for_beneficiaries", "activity.text_for_targets", "activity.target", "activity.budget", "activity.spend", "currency","activity.start", "activity.end", "activity.provider"]
    header.flatten
  end

  def build_row(activity, beneficiaries)
    org        = activity.data_response.responding_organization
    act_benefs = activity.beneficiaries.map(&:to_s)

    row = []
    row << [ "#{h org.name}", "#{org.type}", "#{h activity.name}", "#{h activity.description}" ]
    beneficiaries.each do |ben|
      row << (act_benefs.include?(ben) ? "yes" : " " )
    end
    row << ["#{h activity.text_for_beneficiaries}", "#{h activity.text_for_targets}", "#{activity.target}", "#{activity.budget}", "#{activity.spend}", "#{activity.data_response.currency}",  "#{activity.start}", "#{activity.end}" ]
    row << (activity.provider.nil? ? " " : "#{h activity.provider.name}" )
    row.flatten
  end

end

