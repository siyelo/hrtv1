module ResponsesHelper
  def requested_amounts(response)
    response.request.requested_amounts.join(" or ")
  end
end
