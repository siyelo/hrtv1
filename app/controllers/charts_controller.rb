class ChartsController < ApplicationController

  def project_pie
    @assignments = Project.find(:all,
                                :select => "codes.short_display AS name, SUM(code_assignments.cached_amount) AS value",
                                :joins => {:activities => {:code_assignments => :code}},
                                :conditions => ["projects.id = :project_id AND code_assignments.type = :codings_type AND codes.type = :code_type",
                                  {:project_id => params[:project_id], :codings_type => params[:codings_type], :code_type => params[:code_type]}],
                                :group => "codes.short_display")

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  private

  # csv format for AM pie chart:
  # title, value, ?, ?, ?, description
  def get_csv_string(records)
    other = 0
    csv_string = FasterCSV.generate do |csv|
      records.each_with_index do |record, index|
        if index < 10
          csv << [first_n_words(h(record.name), 3), record.value.to_f, nil, nil, nil, h(record.name) ]
        else
          other += record.value.to_f
        end
      end
      csv << ['Other', other, nil, nil, nil, 'Other']
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

  def first_n_words(string, n)
    string.split(' ').slice(0,n).join(' ') + '...'
  end

end
