if !ModelHelp.find_by_model_name("DataResponseIndex")
  ModelHelp.create(
    :model_name => "DataResponseIndex",
    :short => "Data Reponse Index",
    :long => "Data Reponse Index"
  )
end
if !ModelHelp.find_by_model_name("DataResponseReview")
  ModelHelp.create(
    :model_name => "DataResponseReview",
    :short => "Data Reponse Review",
    :long => "Data Reponse Review"
  )
end
