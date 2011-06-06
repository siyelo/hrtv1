drs = DataResponse.all(:conditions => ["organization_id not in (select id from organizations)"])
drs.each do |dr| dr.delete end
