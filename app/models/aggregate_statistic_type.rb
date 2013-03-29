class AggregateStatisticType < ActiveRecord::Base
  belongs_to :aggregate_statistic
  has_many :aggregate_tender_statistics, :dependent => :destroy
  has_many :aggregate_cpv_statistics, :dependent => :destroy
  has_many :aggregate_bid_statistics, :dependent => :destroy

  attr_accessible :id,
    :aggregate_statistic_id,
    :name
end
