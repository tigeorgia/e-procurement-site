class AddBidDataToTender < ActiveRecord::Migration
  def up
    add_column :tenders, :num_bids, :integer
    add_column :tenders, :num_bidders, :integer
  end

  def down
    remove_column :tenders, :num_bids
    remove_column :tenders, :num_bidders
  end
end
