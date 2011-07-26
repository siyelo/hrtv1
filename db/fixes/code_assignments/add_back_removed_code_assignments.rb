puts "\n  loading code assignments"
FasterCSV.foreach("db/fixes/code_assignments/removed_code_assignments.csv", :headers => true) do |row|
  if row['type'] != 'ServiceLevelBudget' && row['type'] != 'ServiceLevelSpend'
    begin
      print '.'
      c = CodeAssignment.new
      c.id                   = row['id']
      c.activity_id          = row['activity_id']
      c.code_id              = row['code_id']
      c.type                 = row['type']
      c.percentage           = row['percentage']
      c.cached_amount        = row['cached_amount']
      c.sum_of_children      = row['sum_of_children']
      c.created_at           = row['created_at']
      c.updated_at           = row['updated_at']
      c.cached_amount_in_usd = row['cached_amount_in_usd']
      c.save
    rescue
      puts "#{row['id']} already exists"
    end
  end
end
