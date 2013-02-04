class CreateTenderCorruptionFlag < ActiveRecord::Migration
  def change
    create_table :tender_corruption_flag do |t|
      t.integer :tender_id
      t.integer :corruption_indicator_id
      t.integer :value
      t.timestamps
    end
  end
end
