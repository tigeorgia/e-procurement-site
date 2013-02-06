class Competitor < ActiveRecord::Base
  belongs_to :organization

  attr_accessible :id,
  :organization_id,
  :rival_org_id,
  :num_tenders
  validates :organization_id, :rival_org_id, :presence => true
end
