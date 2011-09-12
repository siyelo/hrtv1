module EncodingHelper
  def self.sanitize_encoding(string)
    begin
      Iconv.conv("UTF-8//TRANSLIT//IGNORE", "UTF8", string)
    rescue
      Iconv.conv("UTF-8//TRANSLIT//IGNORE", "UTF8", string + ' ')[0..-1] # //IGNORE only ignores invalid byte sequences
                                                                         # unless they occur right at the end of the string;
    end
  end
end