class ProcurerCpvRevenue < ActiveRecord::Base
  belongs_to :organization
  belongs_to :aggregate_statistic
  attr_accessible :id,
      :organization_id,
      :aggregate_statistic_id,
      :cpv_code,
      :total_value
end
