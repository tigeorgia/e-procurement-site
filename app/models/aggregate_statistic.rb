class AggregateStatistic < ActiveRecord::Base
  has_many :aggregate_statistic_types, :dependent => :destroy
  has_many :aggregate_cpv_revenues, :dependent => :destroy
  attr_accessible :id,
    :year,
    :cpvString,
    :cpvStringGEO
end
