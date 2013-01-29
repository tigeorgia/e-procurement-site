class Organization < ActiveRecord::Base
  has_many :bidders, :dependent => :destroy
  has_many :agreements, :dependent => :destroy
  belongs_to :datasets
  
  attr_accessible :id,
      :dataset_id,
      :organization_url,
      :code,
      :name,
      :country,
      :org_type,
      :is_bidder,
      :is_procurer,
      :city,
      :phone_number,
      :fax_number,
      :email,
      :webpage,
      :address

  validates :organization_url, :presence => true
  
  scope :order_by_name, order("name desc")
  scope :recent, order("name desc").limit(5)
  
  # number of items per page for pagination
	self.per_page = 20
end
