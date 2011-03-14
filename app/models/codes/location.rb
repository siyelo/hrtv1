class Location < Code

  # Associations
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :organizations
  has_one :district, :foreign_key => 'old_location_id'

  # Named scopes
  named_scope :all_with_counters,
                :select => "codes.id, codes.short_display, codes.type,
                  (SELECT COUNT(*) FROM projects
                    INNER JOIN locations_projects ON projects.id = locations_projects.project_id
                    WHERE locations_projects.location_id = codes.id) AS projects_count,
                  (SELECT COUNT(*) FROM organizations
                    INNER JOIN locations_organizations ON organizations.id = locations_organizations.organization_id
                    WHERE locations_organizations.location_id = codes.id) AS organizations_count,
                  (SELECT COUNT(*) FROM activities
                    INNER JOIN activities_locations ON activities.id = activities_locations.activity_id
                    WHERE activities_locations.location_id = codes.id) AS activities_count,
                  SUM(ca1.cached_amount) as spent_sum,
                  SUM(ca2.cached_amount) as budget_sum
                ",
                :joins => "
                  LEFT OUTER JOIN code_assignments ca1 ON codes.id = ca1.code_id
                     AND ca1.type = 'CodingSpendDistrict'
                  LEFT OUTER JOIN code_assignments ca2 ON codes.id = ca2.code_id
                     AND ca2.type = 'CodingBudgetDistrict'
                ",
                :order => "short_display ASC",
                :include => :district,
                :group => "codes.id, codes.short_display, codes.type"
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
#  start_date          :date
#  end_date            :date
#  replacement_code_id :integer
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#  comments_count      :integer         default(0)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

