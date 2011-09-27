module EncodingHelper
  def sanitize_encoding(string)
    if string
      begin
        # //IGNORE ignores invalid byte sequences unless they occur
        # right at the end of the string
        # http://po-ru.com/diary/fixing-invalid-utf-8-in-ruby-revisited/
        Iconv.conv("UTF-8//TRANSLIT//IGNORE", "UTF8", string + ' ')[0..-2]
      rescue Iconv::IllegalSequence
        # //TRANSLIT does not work consistently in all environments
        Iconv.conv("UTF-8//IGNORE", "UTF8", string + ' ')[0..-2]
      end
    end
  end
end