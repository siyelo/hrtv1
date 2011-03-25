module NumberHelper
  include ActionView::Helpers::NumberHelper

  def n2c(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => unit, 
                      :delimiter => ",")
  end
  
  def n2cs(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => "<span class=\"currency-subscript\">#{unit}</span>", 
                      :delimiter => ",", 
                      :format => "%n %u")
  end
  
  def n2crs(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => "<span class=\"currency-subscript\">#{unit}</span>", 
                      :delimiter => ",", 
                      :format => "%n %u")
  end
  
  def n2cr(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => unit, 
                      :delimiter => ",", 
                      :format => "%n %u")
  end
  
end
