module NumberHelper
  include ActionView::Helpers::NumberHelper

  def n2c(value, unit = "")
    number_to_currency(value, :separator => ".", :unit => unit, :delimiter => ",")
  end
end
