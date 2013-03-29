class AggregateTenderStatistic < ActiveRecord::Base
  belongs_to :aggregate_statistic_type
    attr_accessible :id,
    :aggregate_statistic_type_id,
    :count,
    :success_count,
    :total_value,
    :average_bid_duration,
    :average_warning_period,
    :average_bidders,
    :average_bids,
    :total_bidders,
    :total_bids,
    :agreements,
    :illegal_tenders,
    :bidding_times_stats,
    :bidding_warning_stats,
end
