is = ImplementerSplit.all
splits_with_several_is = is.select { |i| (i.budget == nil || i.budget == 0) && (i.spend == nil || i.spend == 0) && i.activity.implementer_splits.count > 1 }
splits_with_several_is.each { |is| is.delete }
