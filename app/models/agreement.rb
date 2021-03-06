class Agreement < ActiveRecord::Base
  belongs_to :tender
  belongs_to :organization
  
  attr_accessible :tender_id,
      :organization_id,
      :organization_url,
      :amount,
      :start_date,
      :expiry_date,
      :documentation_url,
      :amendment_number
      
  validates :tender_id, :organization_id, :presence => true
  
end
