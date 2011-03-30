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
                      :unit => "<span class=\"currency\">#{unit}</span>", 
                      :delimiter => ",", 
                      :format => "%u %u")
  end
  
  def n2crs(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => "<span class=\"currency\">#{unit}</span>", 
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
  
  
  def n2cnd(value, unit = "")
    number_to_currency(value,
                       :separator => ".",
                       :unit => unit,
                       :delimiter => ",",
                       :format => "%u %n",
                       :precision => 0)
  end

  def n2cndr(value, unit = "")
    number_to_currency(value,
                       :separator => ".",
                       :unit => unit,
                       :delimiter => ",",
                       :format => "%n %u",
                       :precision => 0)
  end
  
  def n2cndrs(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => "<span class=\"currency\">#{unit}</span>", 
                      :delimiter => ",", 
                      :format => "%n %u",
                      :precision => 0)
  end
  
  def n2cnds(value, unit = "")
    number_to_currency(value, 
                      :separator => ".", 
                      :unit => "<span class=\"currency\">#{unit}</span>", 
                      :delimiter => ",", 
                      :format => "%u %n",
                      :precision => 0)
  end

end
