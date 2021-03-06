class CreateProcurerWatches < ActiveRecord::Migration
  def change
    create_table :procurer_watches do |t|
      t.integer  "user_id"
      t.string   "procurer_id"
      t.string   "hash"
      t.boolean  "email_alert"
      t.boolean  "has_updated"
      t.timestamps
    end
  end
end
