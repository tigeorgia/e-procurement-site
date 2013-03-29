class CreateAggregateBidStatistics < ActiveRecord::Migration
  def change
    create_table :aggregate_bid_statistics do |t|
      t.integer :aggregate_statistic_type_id
      t.integer :duration
      t.decimal :average_bids, :precision => 11, :scale => 2
      t.integer :tender_count
      t.timestamps
    end
  end
end
