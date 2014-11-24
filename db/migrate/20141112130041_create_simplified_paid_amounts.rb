class CreateSimplifiedPaidAmounts < ActiveRecord::Migration
  def change
    create_table :simplified_paid_amounts do |t|
      t.references :simplified_tender
      t.string :amount_paid
      t.date :amount_date

      t.timestamps
    end
    add_index :simplified_paid_amounts, :simplified_tender_id
  end
end
