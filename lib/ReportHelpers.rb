module ReportHelpers

  @@virtual_coding_types = [:budget_stratprog_coding, :spend_stratprog_coding,
   :budget_stratobj_coding, :spend_stratobj_coding]

  def activity_coding codings_type = nil, code_type = nil
    unless @@virtual_coding_types.include? codings_type.to_sym
      conditions = ["#{self.class.table_name}.id = :my_id "]
      condition_values = {:my_id => id}
      unless codings_type.nil?
        conditions << ["code_assignments.type = :codings_type"]
        condition_values[:codings_type] = codings_type
      end
      unless code_type.nil?
        conditions << ["codes.type = :code_type"]
        condition_values[:code_type] = code_type
      end
      conditions = [conditions.join(" AND "), condition_values]
      name_value = self.class.find(:all,
            :select => "codes.id as code_id, codes.parent_id as parent_id, codes.short_display AS name, SUM(code_assignments.cached_amount) AS value",
            :joins => {:activities => {:code_assignments => :code}},
            :conditions => conditions,
            :group => "codes.short_display, codes.id, codes.parent_id",
            :order => 'value DESC')
      codes_to_exclude = (name_value.collect{|n| n.parent_id} - [nil]).uniq.sort
      c=[]
      name_value.each do |n|
        if codes_to_exclude.include? n.code_id
          c << n.code_id
        end
      end
      c.each do |n|
        name_value.delete_if {|nm| nm.code_id == n}
      end
      name_value
    else
      self.send(codings_type)
    end
  end

  [:budget_stratprog_coding, :spend_stratprog_coding,
   :budget_stratobj_coding, :spend_stratobj_coding].each do |m|
    define_method m do #def m
      name_value= []
      assignments = activities.collect{|a| a.send(m)}.flatten
      assignments.group_by {|a| a.code}.each do |code, array|
        row = [code.short_display, array.inject(0) {|sum, v| sum + v.cached_amount}]
        def row.value
          self[1]
        end
        def row.name
          self[0]
        end
        name_value << row
      end
      name_value
    end
  end

end
