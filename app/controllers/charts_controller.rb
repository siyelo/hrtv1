class ChartsController < ApplicationController

  def project_pie
    @assignments = Project.find(:all, 
                                :select => "codes.short_display AS name, SUM(code_assignments.cached_amount) AS value",
                                :joins => {:activities => {:code_assignments => :code}},
                                :conditions => ["projects.id = :project_id AND code_assignments.type = :codings_type AND codes.type = :code_type", 
                                  {:project_id => params[:project_id], :codings_type => params[:codings_type], :code_type => params[:code_type]}],
                                :group => "codes.short_display",
                                :order => 'value DESC')

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  private
  def get_csv_string(records)
    other = 0
    csv_string = FasterCSV.generate do |csv|
      records.each_with_index do |record, index|
        if index < 10
          csv << [h(record.name), record.value.to_f]
        else
          other += record.value.to_f
        end
      end
      csv << ['Other', other]
    end
    csv_string
  end

  def h(str)
    if str
      str.gsub!(',', '  ')
      str.gsub!("\n", '  ')
      str.gsub!("\t", '  ')
      str.gsub!("\015", "  ") # damn you ^M
    end
    str
  end
end
