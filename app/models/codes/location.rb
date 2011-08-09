class Location < Code
  # Associations
  has_and_belongs_to_many :activities
  has_many :organizations
  has_one :district, :foreign_key => 'old_location_id'

  alias_attribute :name, :short_display

  # Named scopes
  named_scope :all_with_counters,
              lambda { |request_id| {
                :select => "codes.id, codes.short_display, codes.type,
                  (SELECT COUNT(DISTINCT(organizations.id)) FROM organizations
                    INNER JOIN data_responses ON organizations.id = data_responses.organization_id
                    INNER JOIN data_requests ON data_responses.data_request_id = data_requests.id AND data_responses.data_request_id = #{request_id}
                    INNER JOIN activities ON data_responses.id = activities.data_response_id
                    INNER JOIN code_assignments on activities.id = code_assignments.activity_id
                    WHERE code_assignments.code_id = codes.id) AS organizations_count,
                  (SELECT COUNT(DISTINCT(activities.id)) FROM activities
                    INNER JOIN data_responses ON activities.data_response_id = data_responses.id
                    INNER JOIN data_requests ON data_responses.data_request_id = data_requests.id AND data_responses.data_request_id = #{request_id}
                    INNER JOIN code_assignments on activities.id = code_assignments.activity_id
                    WHERE code_assignments.code_id = codes.id) AS activities_count,
                  SUM(ca1.cached_amount) as spent_sum,
                  SUM(ca2.cached_amount) as budget_sum",
                :joins => "
                  LEFT OUTER JOIN code_assignments ca1 ON codes.id = ca1.code_id
                     AND ca1.type = 'CodingSpendDistrict'
                  LEFT OUTER JOIN code_assignments ca2 ON codes.id = ca2.code_id
                     AND ca2.type = 'CodingBudgetDistrict'
                ",
                :order => "short_display ASC",
                :include => :district,
                :group => "codes.id, codes.short_display, codes.type"

              }}

  named_scope :national_level, { :conditions => "lower(codes.short_display) = 'national level'" }
  named_scope :without_national_level, { :conditions => "lower(codes.short_display) != 'national level'" }
  named_scope :sorted, { :order => "codes.short_display" }

end







# == Schema Information
#
# Table name: codes
#
#  id                  :integer         not null, primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :datetime
#  updated_at          :datetime
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

