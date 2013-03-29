class AggregateStatistic < ActiveRecord::Base
  has_many :aggregate_statistic_types, :dependent => :destroy
  attr_accessible :id,
    :year
end
