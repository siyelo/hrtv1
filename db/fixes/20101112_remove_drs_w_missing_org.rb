drs = DataResponse.all(:conditions => ["organization_id_responder not in (select id from organizations)"])
drs.each do |dr| dr.delete end
