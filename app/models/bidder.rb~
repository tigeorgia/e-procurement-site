class Bidder < ActiveRecord::Base
  belongs_to :tender
  belongs_to :organization
  
  attr_accessible :tender_id,
      :organization_url,
      :organization_id,
      :first_bid_amount,
      :first_bid_date,
      :last_bid_amount,
      :last_bid_date
      :number_of_bids
      
  validates :tender_id, :organization_id, :organization_url, :presence => true
  
end
