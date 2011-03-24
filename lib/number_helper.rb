module NumberHelper
  include ActionView::Helpers::NumberHelper

  def n2c(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => unit, 
                      :delimiter => ",")
  end
  
  def report_n2c(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => "<span style=\"font-size: 9px;\">#{unit}</sub>", 
                      :delimiter => ",", 
                      :format => "%n %u")
  end
  
end
