class ChartsController < ApplicationController

  def data_response_pie
    @data_response = DataResponse.available_to(current_user).find(params[:data_response_id])
    @assignments = @data_response.activity_coding(params[:codings_type], params[:code_type])

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  def project_pie
    @project = Project.available_to(current_user).find(params[:project_id])
    @assignments = @project.activity_coding(params[:codings_type], params[:code_type])

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  def data_response_treemap
    data_response = DataResponse.find(params[:data_response_id])
    
    respond_to do |format|
      format.json { render :json => get_data_response_data_rows(data_response, params[:chart_type]) }
    end
  end

  def project_treemap
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

  def get_data_response_data_rows(data_response, chart_type)
    case chart_type
    when 'mtef_budget'
      data_rows = []
      data_rows << ['All Codes',nil,0,0]

      codes = Mtef.all
      roots = Mtef.roots
      codings = CodingBudget.with_code_ids(codes).with_activities(data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      codes.each do |code|
        # ignore parents of a different type
        parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        data_rows << [code.short_display, parent, amount, code.level]
      end

      return data_rows
    when 'mtef_spend'
      data_rows = []
      data_rows << ['All Codes',nil,0,0]

      codes = Mtef.all
      roots = Mtef.roots
      codings = CodingBudget.with_code_ids(codes).with_activities(data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      codes.each do |code|
        # ignore parents of a different type
        parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        data_rows << [code.short_display, parent, amount, code.level]
      end

      return data_rows
    when 'nsp_budget'
      codes = Nsp.all
      roots = Nsp.roots

      new_data_rows = Code.treemap_for_codes(roots, codes, "CodingBudget", data_response.activities)

      return new_data_rows
    when 'nsp_spend'
      data_rows = []
      data_rows << ['All Codes',nil,0,0]

      codes = Nsp.all
      roots = Nsp.roots
      codings = CodingBudget.with_code_ids(codes).with_activities(data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      codes.each do |code|
        # ignore parents of a different type
        parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        data_rows << [code.short_display, parent, amount, code.level]
      end

      return data_rows
    else
      raise "Wrong chart type".to_yaml
    end
  end
end
