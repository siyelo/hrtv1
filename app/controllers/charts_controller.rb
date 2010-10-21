class ChartsController < ApplicationController

  def project_pie
    @project = Project.available_to(current_user).find params[:project_id]
#    if params[:codings_type].try("include?", "Strat"
    @assignments = @project.activity_coding params[:codings_type], params[:code_type]

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  def data_response_pie
    @data_response = DataResponse.available_to(current_user).find params[:data_response_id]
    @assignments = @data_response.activity_coding params[:codings_type], params[:code_type]

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  private

  # csv format for AM pie chart:
  # title, value, ?, ?, ?, description
  def get_csv_string(records)
    other = 0
    logger.debug "records: #{records.to_s}"
    csv_string = FasterCSV.generate do |csv|
      records.each_with_index do |record, index|
        if index < 10
	  logger.debug "wrote #{record.code_id}"
          csv << [first_n_words(h(record.name), 3), record.value.to_f, nil, nil, nil, h(record.name) ]
        else
	  logger.debug "wrote #{record.code_id} as other"
          other += record.value.to_f
        end
      end
      csv << ['Other', other, nil, nil, nil, 'Other']
    end
    logger.debug csv_string
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
