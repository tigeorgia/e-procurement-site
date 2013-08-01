 class Tender < ActiveRecord::Base
  include Updateable

  has_many :bidders, :dependent => :destroy
  has_many :agreements, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :tender_corruption_flags, :dependent => :destroy
  belongs_to :dataset





  attr_accessible :id,
      :url_id,
      :dataset_id,
      :procurring_entity_id,
      :tender_type,
      :tender_registration_number,
      :tender_status,
      :tender_announcement_date,
      :bid_start_date,
      :bid_end_date,
      :estimated_value,
      :include_vat,
      :cpv_code,
      :addition_info,
      :units_to_supply,
      :supply_period,
      :offer_step,
      :guarantee_amount,
      :guarantee_period,
      :num_bids,
      :num_bidders

  validates :url_id, :tender_type, :tender_registration_number, :tender_status, :presence => true
  
  scope :recent, order("tender_announcement_date desc").limit(5)
  
  # number of items per page for pagination
  self.per_page = 100

  HUMANREADABLE = {
    "procurer_name" => "Procurer",
    "tender_type" => "Tender Type",
    "tender_registration_number" => "Procurement Code",
    "tender_status" => "Tender Status",
    "tender_announcement_date" => "Announcement Date",
    "bid_start_date" => "Bidding Start Date",
    "bid_end_date" => "Bidding End Date",
    "estimated_value" => "Estimated Cost",
    "cpv_code" => "CPV Code",
    "addition_info" => "Additional Information"
  }
  
  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |tender|
        csv << tender.attributes.values_at(*column_names)
      end
    end
  end
end
