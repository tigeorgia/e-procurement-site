class ProcurerCpvRevenue < ActiveRecord::Base
  belongs_to :organization 
  attr_accessible :id,
      :organization_id,
      :cpv_code,
      :total_value
end
