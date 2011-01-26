d = DataResponse.find(6669)
  code_ids = Mtef.roots.map(&:id)

  puts "org \tproject name \ta.id \ta.name \ta.spend \ta.cached_spend \ca.split_spend_district"

  puts d.organization.name

  tot_act_sum = 0
  tot_act_csd_sum = 0
  tot_csd_ca_usd_sum = 0

  d.projects.each do |p|
    puts "\t#{p.name}"
    act_sum = 0
    act_csd_sum = 0
    csd_ca_usd = 0
    csd_ca_usd_sum = 0

    p.activities.each do |a|
      act_sum += a.spend || 0
      act_csd_sum += a.CodingSpendDistrict_amount || 0
      csd_ca_usd = CodingSpend.with_activity(a).with_code_ids(code_ids).sum('new_cached_amount_in_usd')
      #debugger if a.spend.to_s == "42753120.0"
      am = Money.new((a.spend.to_f.round(2)*100).to_i, :RWF)
      m = Money.new(csd_ca_usd, 'USD').exchange_to(:RWF)
      csd_ca_usd_sum += m.cents
      print "\t\t#{a.id}"
      print "\t"
      print a.name.first(20) unless a.name.blank?
      print "\t" + a.spend.to_s
      print "\t" + a.CodingSpendDistrict_amount.to_s
      print "\t" + m.to_s
      print "\n"
    end

    puts "\t\t\t\t" +
          act_sum.to_s + "\t" +
          act_csd_sum.to_s + "\t" +
          csd_ca_usd_sum.to_s

    tot_act_sum +=    act_sum || 0
    tot_act_csd_sum +=    act_csd_sum || 0
    tot_csd_ca_usd_sum +=    csd_ca_usd_sum || 0
  end

  print "\t\t\t\t"
  print tot_act_sum.to_s + "\t"
  print tot_act_csd_sum.to_s + "\t"
  print tot_csd_ca_usd_sum.to_s
  print "\n"