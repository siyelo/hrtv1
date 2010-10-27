module ChartsHelper

  def get_data_rows(data_response, chart_type)
    case chart_type
    when 'mtef_budget'
      data_rows = "data.addRows([  ['All Codes',null,0,0],\r"

      codes = Mtef.all
      roots = Mtef.roots
      codings = CodingBudget.with_code_ids(codes).with_activities(data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      codes.each do |code|
        # ignore parents of a different type
        parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        data_rows << "            ['#{code.short_display}', '#{parent}', #{amount}, #{code.level}],\r"
      end

      # strip last comma
      data_rows = data_rows[0..(data_rows.rindex(',')-1)]
      data_rows << "  ]); "

      return data_rows

    when 'mtef_spend'
      data_rows = "data.addRows([  ['All Codes',null,0,0],\r"

      codes = Mtef.all
      roots = Mtef.roots
      codings = CodingBudget.with_code_ids(codes).with_activities(@data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      codes.each do |code|
        # ignore parents of a different type
        parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        data_rows << "            ['#{code.short_display}', '#{parent}', #{amount}, #{code.level}],\r"
      end

      # strip last comma
      data_rows = data_rows[0..(data_rows.rindex(',')-1)]
      data_rows << "  ]); "

      return data_rows


    when 'nsp_budget'
      front = "data.addRows([ "
      data_rows = ["['All Codes',null,0,0]"]

      codes = Nsp.all
      roots = Nsp.roots

      new_data_rows = Code.treemap_for_codes(roots, codes, "CodingBudget", @data_response.activities)
      #codings = CodingBudget.with_code_ids(codes).with_activities(@data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      #codes.each do |code|
        ## ignore parents of a different type
        #parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        #amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        #data_rows << code.treemap_row_for( code.short_display, parent, amount, code.level)
      #end

      ## strip last comma
      #data_rows = data_rows.join(",\r")
      #data_rows = front + data_rows + "  ]); "

      return new_data_rows

    when 'nsp_spend'
      data_rows = "data.addRows([  ['All Codes',null,0,0],\r"

      codes = Nsp.all
      roots = Nsp.roots
      codings = CodingBudget.with_code_ids(codes).with_activities(@data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      codes.each do |code|
        # ignore parents of a different type
        parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        data_rows << "            ['#{code.short_display}', '#{parent}', #{amount}, #{code.level}],\r"
      end

      # strip last comma
      data_rows = data_rows[0..(data_rows.rindex(',')-1)]
      data_rows << "  ]); "

      return data_rows
    end
  end
end
