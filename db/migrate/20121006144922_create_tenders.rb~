class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.integer :procurring_entity_id
      t.string :tender_type
      t.string :tender_registration_number
      t.string :tender_status
      t.date :tender_announcement_date
      t.date :bid_start_date
      t.date :bid_end_date
      t.decimal :estimated_value, :precision => 11, :scale => 2
      t.boolean :include_vat, :default => false
      t.string :cpv_code
      t.string :addition_info
      t.string :units_to_supply
      t.string :supply_period
      t.string :offer_step
      t.string :guarantee_amount
      t.string :guarantee_period

      t.timestamps
    end
  
    
    add_index :tenders, :procurring_entity_id
    add_index :tenders, :tender_type
    add_index :tenders, :tender_status
    add_index :tenders, :estimated_value
  end
end
