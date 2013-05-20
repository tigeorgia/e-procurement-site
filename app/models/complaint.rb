class Complaint < ActiveRecord::Base
  attr_accessible :id,
    :status,
    :organization_id,
    :tender_id,
    :complaint,
    :legalBasis,
    :demand
end
