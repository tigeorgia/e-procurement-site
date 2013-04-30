class CreateSupplierWatches < ActiveRecord::Migration
  def change
    create_table :supplier_watches do |t|
      t.integer  "user_id"
      t.string   "supplier_id"
      t.string   "hash"
      t.boolean  "email_alert"
      t.boolean  "has_updated"
      t.timestamps
    end
  end
end
