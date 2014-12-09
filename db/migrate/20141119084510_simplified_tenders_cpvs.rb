class SimplifiedTendersCpvs < ActiveRecord::Migration
  def self.up
    create_table :simplified_tenders_cpvs, :id => false do |t|
        t.references :simplified_tender
        t.references :simplified_cpv
    end
    add_index :simplified_tenders_cpvs, :simplified_tender_id
  end

  def self.down
    drop_table :simplified_tenders_cpvs
  end  
end
