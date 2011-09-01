class ImproveBeneficiaries < ActiveRecord::Migration
  def self.up
    b = Beneficiary.new(:short_display => 'Infants (0-12months)')
    b.save!

    b = Beneficiary.new(:short_display => 'Young children (1-4 years)')
    b.save!

    if (b = Beneficiary.find_by_short_display "Young people")
      b.short_display = "School-age children (5-14 years)"
      b.save!
    end

    b = Beneficiary.new(:short_display => 'Men of reproductive age (15-44 years)')
    b.save!

    if (b = Beneficiary.find_by_short_display "Women")
      b.short_display = "Women of reproductive age (15-44 years)"
      b.save!
    end

    b = Beneficiary.new(:short_display => 'Adults (45 and above)')
    b.save!
  end

  def self.down
    puts "reversing this is a WOFTAM"
  end
end
