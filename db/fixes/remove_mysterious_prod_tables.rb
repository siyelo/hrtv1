# clean up some bad tables that were created without migrations on prod
require 'db/migrate/20110317123051_create_commodities.rb'
CreateCommodities.down

require 'db/migrate/20110322145249_create_funding_sources.rb'
CreateFundingSources.down

require 'db/migrate/20110413113853_create_funding_streams.rb'
CreateFundingStreams.down
