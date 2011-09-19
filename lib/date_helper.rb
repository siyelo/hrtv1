module DateHelper
  def self.flexible_date_parse(date_string)
    date_string = date_string.to_s[0..9] if date_string.to_s.length > 10 #remove the time if it is included
    begin
      Date.parse(date_string.gsub('/', '-'))
    rescue
      Date.strptime(date_string.gsub('/', '-'), '%d-%m-%Y') rescue date_string
    end
  end
end
