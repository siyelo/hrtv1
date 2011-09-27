require 'spreadsheet'

# Exporting files (via controller actions)
module Exporter
  def send_csv(data, filename)
    send_file(data, filename, "text/csv; charset=iso-8859-1; header=present")
  end

  def send_xls(data, filename)
    send_file(data, filename, "application/excel")
  end

  def send_file(data, filename, type = "text/csv; charset=iso-8859-1; header=present")
    send_data data, :type => type,
              :disposition=>"attachment; filename=#{filename}"
  end

  def self.to_xls(rows = [])
    Spreadsheet.client_encoding = "UTF-8//IGNORE"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    rows.each_with_index do |row, row_index|
      row.each_with_index do |cell, column_index|
        sheet1[row_index, column_index] = cell
      end
    end

    data = StringIO.new ''
    book.write data
    data.string
  end

  def self.to_csv(rows = [])
    FasterCSV.generate do |csv|
      rows.each do |row|
        csv << row
      end
    end
  end
end