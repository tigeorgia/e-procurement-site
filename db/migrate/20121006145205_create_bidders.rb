class CreateBidders < ActiveRecord::Migration
  def change
    create_table :bidders do |t|
      t.integer :tender_id
      t.integer :organization_url
      t.integer :organization_id
      t.decimal :first_bid_amount, :precision => 11, :scale => 2
      t.date :first_bid_date
      t.decimal :last_bid_amount, :precision => 11, :scale => 2
      t.date :last_bid_date
      t.integer :number_of_bids

      t.timestamps
    end
    
    add_index :bidders, [:tender_id, :organization_id]
  end
end
