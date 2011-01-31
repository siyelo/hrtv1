require 'fastercsv'

id_col            = 2
type_col          = 8

csv = FasterCSV.generate do |csv|
  # header
  row = ["external_id", "problem"]
  csv << row

  FasterCSV.foreach("db/seed_files/codes.csv", :headers => true) do |row|

    unless row[type_col]
      klass_string = "Code" #Assume default
    else
      unless row[type_col].include? "HsspS" #this should make STI stop complaining
        klass_string = row[type_col].capitalize
      else
        klass_string = row[type_col]
      end
    end
    klass_string = "Nha" if klass_string.downcase == "nhanasa"

    original_code = Code.find(:all, :conditions => ['external_id = ? AND type = ?',
                                                  row[id_col], klass_string])

    if original_code.length == 1
      # do nothing it is ok
    elsif original_code.length > 1
      csv <<  [row[id_col], "Duplicate codes with ids #{original_code.map(&:id).join(', ')}"]
    else
      problematic_code = Code.find_by_external_id(row[id_col])
      if problematic_code
        csv << [row[id_col], "Wrong type for code with id: #{problematic_code.id}"]
      else
        csv << [row[id_col], "Missing code with external_id: #{row[id_col]}"]
      end
    end
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'codes_check.csv'), 'w') do |file|
  file.puts csv
end
