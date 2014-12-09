class SimplifiedTender < ActiveRecord::Base
  include Updateable

  attr_accessible :id,
                  :registration_number,
                  :status,
                  :supplier_id,
                  :procuring_entity_id

  has_and_belongs_to_many :simplified_cpvs, join_table: 'simplified_tenders_cpvs'
  has_many :simplified_paid_amounts
  has_many :simplified_attachments
  belongs_to :supplier, :class_name => "Organization"
  belongs_to :procuring_entity, :class_name => "Organization"

  scope :order_by_name, order("regitration_number desc")
  scope :recent, order("regitration_number desc").limit(5)

  # number of items per page for pagination
  self.per_page = 20

end
