class TenderCpvCode < ActiveRecord::Base
  belongs_to :tender  
  attr_accessible :id,
      :tender_id,
      :cpv_code,
      :description,
      :english_description
end
