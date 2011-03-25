class Commodity < ActiveRecord::Base
  belongs_to :data_response
  
  #Validations
  validates_presence_of :data_response_id, :commodity_type, :description
  validates_numericality_of :unit_cost, :quantity
  
  ### Constants
  FILE_UPLOAD_COLUMNS = %w[commodity_type description unit_cost quantity]

  #Methods
  def calculate_total
    self.unit_cost * self.quantity
  end
  
  def self.from_csv(file, data_response)
    doc = FasterCSV.parse(file.open.read, {:headers => true})
    if doc.headers.to_set == Commodity::FILE_UPLOAD_COLUMNS.to_set
      saved, errors = create_from_file(doc, data_response)
      { :result => true, :message => "Created #{saved} of #{saved + errors} commodities successfully" }
    else
      { :result => false, :message => "Wrong fields mapping. Please download the CSV template" }
    end
  end
  
  def self.create_from_file(doc, data_response)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash if CostCategory.roots.map(&:short_display).include?(row["commodity_type"])
      commodity = data_response.commodities.new(attributes)
      commodity.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
  end
  
  def self.download_template
    FasterCSV.generate do |csv|
      csv << Commodity::FILE_UPLOAD_COLUMNS
    end
  end
end



# == Schema Information
#
# Table name: commodities
#
#  id               :integer         not null, primary key
#  commodity_type   :string(255)
#  description      :text
#  unit_cost        :decimal(, )     default(0.0)
#  quantity         :integer
#  data_response_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

