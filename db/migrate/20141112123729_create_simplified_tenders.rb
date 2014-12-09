class CreateSimplifiedTenders < ActiveRecord::Migration
  def change
    create_table :simplified_tenders do |t|
      t.string :registration_number
      t.string :status
      t.integer :procuring_entity_id
      t.integer :supplier_id
      t.string :contract_value
      t.date :contract_value_date
      t.date :doc_start_date
      t.date :doc_end_date
      t.string :agreement_amount
      t.string :agreement_done

      t.timestamps
    end
  end
end
