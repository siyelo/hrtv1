module ChartsHelper

  def get_data_rows(data_response, chart_type)
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
      codings = CodingBudget.with_code_ids(codes).with_activities(@data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

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

      new_data_rows = Code.treemap_for_codes(roots, codes, "CodingBudget", @data_response.activities)

      return new_data_rows
    when 'nsp_spend'
      data_rows = []
      data_rows << ['All Codes',nil,0,0]

      codes = Nsp.all
      roots = Nsp.roots
      codings = CodingBudget.with_code_ids(codes).with_activities(@data_response.activities).all.map_to_hash{ |b| {b.code_id => b} }

      codes.each do |code|
        # ignore parents of a different type
        parent = roots.include?(code) ? 'All Codes' : code.parent.short_display
        amount = codings[code.id].nil? ? 0 : codings[code.id].calculated_amount
        data_rows << [code.short_display, parent, amount, code.level]
      end

      return data_rows
    end
  end

  def get_treemap_data(data_response, chart_types)
    treemap_data = {}

    chart_types.each do |chart_type|
      treemap_data[chart_type] = {:chart_id => get_chart_id_tree(data_response, chart_type), :data_rows => get_data_rows(data_response, chart_type)}
    end

    treemap_data.to_json
  end

  def get_chart_id_tree(data_response, chart_type)
    "dr_#{data_response.id}_#{chart_type}_tree"
  end

  def get_chart_id_pie(data_response, chart_type)
    "dr_#{data_response.id}_#{chart_type}"
  end
end
