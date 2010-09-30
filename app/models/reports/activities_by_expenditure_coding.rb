require 'fastercsv'

class Reports::ActivitiesByExpenditureCoding
  include Reports::Helpers

  def initialize

    codes = []
    code_ids = []
    Code.roots.reject { |r| ! [Mtef, Nha, Nasa, Nsp].include? r.class }.each do |c|
      codes << c.self_and_descendants.map { |e| e.short_display + " (" + (e.external_id.nil? ? 'n/a': e.external_id) + ")" }
      code_ids << c.self_and_descendants.map(&:id)
    end
    codes.flatten!
    code_ids.flatten!

    beneficiaries = Beneficiary.find(:all, :select => 'short_display').map(&:short_display).sort

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header(beneficiaries, codes)

      #print data
      Activity.all.each do |a|
        row = build_row(a, beneficiaries, code_ids)
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
    codes.each do |code|
      header << "#{code}"
    end
    header.flatten
  end

  def build_row(activity, beneficiaries, code_ids)
    org        = activity.data_response.responding_organization
    act_benefs = activity.beneficiaries.map(&:short_display)
    act_codes  = activity.expenditure_codes.map(&:id)

    row = []
    row << [ "#{h org.name}", "#{org.type}", "#{h activity.name}", "#{h activity.description}" ]
    beneficiaries.each do |ben|
      row << (act_benefs.include?(ben) ? "yes" : " " )
    end
    row << ["#{h activity.text_for_beneficiaries}", "#{h activity.text_for_targets}", "#{activity.target}", "#{activity.budget}","#{activity.spend}", "#{activity.data_response.currency}",  "#{activity.start}", "#{activity.end}" ]
    row << (activity.provider.nil? ? " " : "#{h activity.provider.name}" )
    code_ids.each do |code_id|
      if act_codes.include?(code_id)
        ca = CodeAssignment.find(:first, :conditions => {:activity_id => activity.id, :code_id => code_id})
        unless ca.amount.nil?
          row << ca.amount
        else
          row << "#{ca.percentage}%"
        end
      else
        row << " "
      end
    end
    row.flatten
  end

end

