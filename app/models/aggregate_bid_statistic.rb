class AggregateBidStatistic < ActiveRecord::Base
  belongs_to :aggregate_statistic_type
    attr_accessible :id,
    :aggregate_statistic_type_id

end
