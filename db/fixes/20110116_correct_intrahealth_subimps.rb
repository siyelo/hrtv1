# seed code values
#
# Expected Columns

puts "Loading intrahealth_budget.csv..."
# if we do lookups by col id, not name, then FasterCSV
# is more forgiving with (non)/quoted csv's

# indices start at 0
provider_col            = 1

i = 0
dr = data_response = DataResponse.find(6550) #looked up in console #drs.first unless drs.size > 1
pivot_table_hash = {}
pivot_attribs = nil
FasterCSV.foreach("db/fixes/intrahealth_budgets.csv", :headers=>false) do |row|
  begin
    i = i + 1
    #puts row.inspect
    if i == 1 #first row
      pivot_attribs = row.clone
    else
      row_hash = {}
      ((provider_col+1)...row.size).each do |pivot_val_index|
        row_hash[pivot_attribs[pivot_val_index]] = row[pivot_val_index] if row[pivot_val_index] != nil
      end
      pivot_table_hash[row[provider_col]] = row_hash
    end
  end
end

#puts pivot_table_hash.inspect
#puts pivot_attribs.inspect

#this mapping is just a draft, doesn't actually work except for TB/HIV
map_budget_input_file_to_activity_description = { 
  "Paediatric Treatment (PDTX) (5%)" => "PDTX",
 "Prevention to Mother to Child Transmission(MTCT) (4.9%)/65%" => "MTCT",
 "TB/HIV (2.09%)" => "TB/HIV",
 "Maternal Child Health(MCH) (6.52%)" => "MCH",
 "Family Planning (6.52%)" => "6",
 "Adulth Treatment(HTXS) (47.93%)" => "HTXS",
 "Paediatric Care & Support (PDCS)(5.4%)" => "PDCS",
 "Adult Care & Support (HBHC) (19.2%)" => "HBHC",
 "Voluntary Couselling and Testing (HVCT) (2.44%)/35%" => "HVCT"}

#actual activity descriptions (taken from console)
#["Adult Care and Support (HBHC)",  "Adult treatment(HTXS)", "Testing and Couselling(HVCT)", "TB/HIV", "Prevention for Mother to Child Transmission(MTCT)", "Paediatric Care and Support (PDCS", "Paediatric Treatment (PDTX)", "Maternal Child Health(MCH)", "Family Planning program"]

#use map to look up activity under intrahealth, then map 
# provider names that are the keys of pivot_table_hash
# to then create sub activities

#e.g. first row of budgets file after the header
# creates two subactivities, both with same provider,
# one with budget of 34,555 under activity w description "Prevention for Mother to Child Transmission(MTCT)"
# other with budget of 18,606 under activity w description "Testing and Couselling(HVCT)"


#then, after budgets done, do same for spent file
